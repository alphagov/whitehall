# Statistics Announcements can be found at
# https://www.gov.uk/search/research-and-statistics?content_store_document_type=upcoming_statistics
#
# They are used to announce the publication of official statistics. Some info
# can be found in the Wiki - https://gov-uk.atlassian.net/wiki/display/GOVUK/Statistics.
#
# Once the statistics are published, the statistics announcement will redirect and
# disappear from search.
#
# Statistics Announcements pages are rendered by the `government-frontend` app,
# the index page is still rendered from Whitehall.
#
# Statistics announcements are not versioned/editioned.
class StatisticsAnnouncement < ApplicationRecord
  extend FriendlyId
  friendly_id :title
  include PublishesToPublishingApi

  def can_publish_to_publishing_api?
    super && !publication_has_been_published? && !unpublished?
  end

  belongs_to :creator, class_name: "User"
  belongs_to :cancelled_by, class_name: "User"
  belongs_to :publication, autosave: true, validate: false
  validates_associated :publication, if: :publication,
                                     message: lambda { |_, publication|
                                       "type #{publication[:value].errors[:publication_type_id].first}"
                                     }

  has_one :current_release_date,
          lambda {
            joins(:statistics_announcement)
              .where("statistics_announcements.current_release_date_id = statistics_announcement_dates.id")
          },
          class_name: "StatisticsAnnouncementDate",
          inverse_of: :statistics_announcement
  has_many :statistics_announcement_dates,
           -> { order(created_at: :asc, id: :asc) },
           dependent: :destroy

  has_many :statistics_announcement_organisations, inverse_of: :statistics_announcement, dependent: :destroy
  has_many :organisations, through: :statistics_announcement_organisations

  validate :redirect_not_circular, if: :unpublished?
  validates :publishing_state, inclusion: %w[published unpublished]
  validates :redirect_url, presence: { message: "must be provided when unpublishing an announcement" }, if: :unpublished?
  validates :redirect_url, uri: true, allow_blank: true
  validates :redirect_url, gov_uk_url_format: true, allow_blank: true
  validates :title, :summary, :organisations, :creator, :statistics_announcement_dates, presence: true
  validates :cancellation_reason, presence: { message: "must be provided when cancelling an announcement" }, if: :cancelled?
  validates :publication_type_id,
            inclusion: {
              in: PublicationType.statistical.map(&:id),
              message: "must be a statistical type",
            }

  accepts_nested_attributes_for :statistics_announcement_dates

  scope :with_title_containing,
        lambda { |*keywords|
          pattern = "(#{keywords.map { |k| Regexp.escape(k) }.join('|')})"
          where("statistics_announcements.title REGEXP :pattern OR statistics_announcements.slug = :slug", pattern:, slug: keywords)
        }
  scope :in_organisations,
        lambda { |organisation_ids|
          joins(:statistics_announcement_organisations)
            .where(statistics_announcement_organisations: { organisation_id: organisation_ids })
        }
  scope :published, -> { where(publishing_state: "published") }

  default_scope { published }

  include Searchable
  searchable  only: :without_published_publication,
              title: :title,
              link: :base_path,
              description: :summary,
              display_date: :display_date,
              display_type: :display_type,
              slug: :slug,
              organisations: :organisations_slugs,
              public_timestamp: :updated_at,
              release_timestamp: :release_date,
              statistics_announcement_state: :state,
              metadata: :search_metadata,
              index_after: [],
              unindex_after: []

  delegate :release_date,
           :display_date,
           :confirmed?,
           to: :current_release_date,
           allow_nil: true

  after_touch :publish_redirect_to_publication, if: :publication_has_been_published?
  set_callback :published, :after, :after_publish
  before_validation :update_associated_publication_type, on: :update, if: :publication_type_id_changed?
  after_commit :notify_unpublished, if: :unpublished?

  def notify_unpublished
    publish_redirect_to_redirect_url
    remove_from_search_index
    update_publish_intent
  end

  def after_publish
    update_in_search_index
    update_publish_intent
  end

  def update_publish_intent
    if unpublished? || cancelled?
      PublishingApiUnscheduleWorker.perform_async(base_path)
    else
      PublishingApiScheduleWorker.perform_async(base_path, statistics_announcement_dates.last.release_date.to_s)
    end
  end

  def self.without_published_publication
    includes(:publication)
      .references(:editions)
      .where("editions.id IS NULL || editions.state NOT IN (?)", Edition::POST_PUBLICATION_STATES)
  end

  def self.with_topics(topic_ids)
    joins(:statistics_announcement_topics)
      .where(statistics_announcement_topics: { topic_id: topic_ids })
  end

  def last_change_note
    last_major_change.try(:change_note)
  end

  def previous_display_date
    if last_major_change
      major_change_index = statistics_announcement_dates.order(:created_at).index(last_major_change)
      statistics_announcement_dates.to_a.at(major_change_index - 1).try(:display_date)
    end
  end

  def display_type
    I18n.t("document.type.#{display_type_key}", count: 1)
  end

  def display_type_key
    publication_type.key
  end

  def publication_type
    PublicationType.find_by_id(publication_type_id)
  end

  def base_path
    "/government/statistics/announcements/#{slug}"
  end

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def public_url(options = {})
    Plek.website_root + public_path(options)
  end

  alias_method :search_link, :base_path

  def organisations_slugs
    organisations.map(&:slug)
  end

  def search_metadata
    {
      confirmed: confirmed?,
      display_date:,
      change_note: last_change_note,
      previous_display_date:,
      cancelled_at:,
      cancellation_reason:,
    }
  end

  def build_statistics_announcement_date_change(attributes = {})
    current_date_attributes = current_release_date.attributes.slice("release_date", "confirmed", "precision")

    StatisticsAnnouncementDateChange.new(attributes.reverse_merge(current_date_attributes)) do |change|
      change.statistics_announcement = self
      change.current_release_date = current_release_date
    end
  end

  def cancel!(reason, user)
    self.cancellation_reason = reason
    self.cancelled_at = Time.zone.now
    self.cancelled_by = user
    save # rubocop:disable Rails/SaveBang
  end

  def cancelled?
    cancelled_at.present?
  end

  def national_statistic?
    publication_type == PublicationType::NationalStatistics
  end

  def state
    if cancelled?
      "cancelled"
    elsif confirmed?
      "confirmed"
    else
      "provisional"
    end
  end

  def unpublished?
    publishing_state == "unpublished"
  end

  def requires_redirect?
    unpublished? || publication_has_been_published?
  end

  def publishing_api_presenter
    PublishingApi::StatisticsAnnouncementPresenter
  end

  def update_current_release_date
    latest = statistics_announcement_dates.reverse_order
    update!(current_release_date_id: latest.pick(:id))
    reload_current_release_date
  end

private

  def update_associated_publication_type
    publication.publication_type_id = publication_type_id if publication
  end

  def publication_has_been_published?
    publication && publication.published?
  end

  def publication_url
    publication.base_path
  end

  def last_major_change
    statistics_announcement_dates
      .where("change_note IS NOT NULL && change_note != ?", "")
      .order(:created_at)
      .last
  end

  def redirect_not_circular
    if redirect_url.present? && (base_path == redirect_url)
      errors.add(:redirect_url, "cannot redirect to itself")
    end
  end

  def publish_redirect_to_publication
    Whitehall::PublishingApi.publish_redirect_async(content_id, publication_url)
  end

  def publish_redirect_to_redirect_url
    Whitehall::PublishingApi.publish_redirect_async(content_id, redirect_path)
  end

  def redirect_uri
    @redirect_uri ||= begin
      return if redirect_url.nil?

      Addressable::URI.parse(redirect_url)
    rescue URI::InvalidURIError
      nil
    end
  end

  def redirect_path
    return if redirect_uri.nil?

    path = redirect_uri.path
    path << "##{redirect_uri.fragment}" if redirect_uri.fragment.present?
    path
  end
end
