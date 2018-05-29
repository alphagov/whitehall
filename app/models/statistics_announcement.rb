# Statistics Announcements can be found at https://www.gov.uk/government/statistics/announcements
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

  belongs_to :creator, class_name: 'User'
  belongs_to :cancelled_by, class_name: 'User'
  belongs_to :publication

  has_one  :current_release_date,
    -> { order('created_at DESC') },
    class_name: 'StatisticsAnnouncementDate',
    inverse_of: :statistics_announcement
  has_many :statistics_announcement_dates, dependent: :destroy

  # DID YOU MEAN: Policy Area?
  # "Policy area" is the newer name for "topic"
  # (https://www.gov.uk/government/topics)
  # "Topic" is the newer name for "specialist sector"
  # (https://www.gov.uk/topic)
  # You can help improve this code by renaming all usages of this field to use
  # the new terminology.
  has_many :statistics_announcement_topics, inverse_of: :statistics_announcement, dependent: :destroy
  has_many :topics, through: :statistics_announcement_topics

  has_many :statistics_announcement_organisations, inverse_of: :statistics_announcement, dependent: :destroy
  has_many :organisations, through: :statistics_announcement_organisations

  validate  :publication_is_matching_type, if: :publication
  validate  :redirect_not_circular, if: :unpublished?
  validates :publishing_state, inclusion: %w{published unpublished}
  validates :redirect_url, presence: { message: "must be provided when unpublishing an announcement" }, if: :unpublished?
  validates :redirect_url, uri: true, allow_blank: true
  validates :redirect_url, gov_uk_url: true, allow_blank: true
  validates :title, :summary, :organisations, :topics, :creator, :current_release_date, presence: true
  validates :cancellation_reason, presence: { message: "must be provided when cancelling an announcement" }, if: :cancelled?
  validates :publication_type_id,
              inclusion: {
                in: PublicationType.statistical.map(&:id),
                message: 'must be a statistical type'
              }

  accepts_nested_attributes_for :current_release_date, reject_if: :persisted?

  scope :with_title_containing, ->(*keywords) {
    pattern = "(#{keywords.map { |k| Regexp.escape(k) }.join('|')})"
    where("statistics_announcements.title REGEXP :pattern OR statistics_announcements.slug = :slug", pattern: pattern, slug: keywords)
  }
  scope :in_organisations, ->(organisation_ids) {
    joins(:statistics_announcement_organisations)
      .where(statistics_announcement_organisations: { organisation_id: organisation_ids })
  }
  scope :published, -> { where(publishing_state: "published") }

  default_scope { published }

  include Searchable
  searchable  only: :without_published_publication,
              title: :title,
              link: :public_path,
              description: :summary,
              display_type: :display_type,
              slug: :slug,
              organisations: :organisations_slugs,
              policy_areas: :topic_slugs,
              release_timestamp: :release_date,
              statistics_announcement_state: :state,
              metadata: :search_metadata,
              index_after: [],
              unindex_after: []

  delegate :release_date, :display_date, :confirmed?,
              to: :current_release_date, allow_nil: true

  after_touch :publish_redirect_to_publication, if: :publication_has_been_published?
  set_callback :published, :after, :after_publish
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
      PublishingApiScheduleWorker.perform_async(base_path, statistics_announcement_dates.last.release_date)
    end
  end

  def self.without_published_publication
    includes(:publication).
      references(:editions).
      where("editions.id IS NULL || editions.state NOT IN (?)", Edition::POST_PUBLICATION_STATES)
  end

  def self.with_topics(topic_ids)
    joins(:statistics_announcement_topics).
    where(statistics_announcement_topics: { topic_id: topic_ids })
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
    publication_type.singular_name
  end

  def publication_type
    PublicationType.find_by_id(publication_type_id)
  end

  def public_path
    Whitehall.url_maker.statistics_announcement_path(self)
  end

  alias_method :base_path, :public_path
  alias_method :search_link, :public_path

  def organisations_slugs
    organisations.map(&:slug)
  end

  def topic_slugs
    topics.map(&:slug)
  end

  def search_metadata
    {
      confirmed: confirmed?,
      display_date: display_date,
      change_note: last_change_note,
      previous_display_date: previous_display_date,
      cancelled_at: cancelled_at,
      cancellation_reason: cancellation_reason,
    }
  end

  def build_statistics_announcement_date_change(attributes = {})
    current_date_attributes = current_release_date.attributes.slice('release_date', 'confirmed', 'precision')

    StatisticsAnnouncementDateChange.new(attributes.reverse_merge(current_date_attributes)) do |change|
      change.statistics_announcement = self
      change.current_release_date = current_release_date
    end
  end

  def cancel!(reason, user)
    self.cancellation_reason = reason
    self.cancelled_at = Time.zone.now
    self.cancelled_by = user
    self.save
  end

  def cancelled?
    cancelled_at.present?
  end

  def national_statistic?
    publication_type == PublicationType::NationalStatistics
  end

  def state
    if cancelled?
      'cancelled'
    elsif confirmed?
      'confirmed'
    else
      'provisional'
    end
  end

  def unpublished?
    publishing_state == "unpublished"
  end

  def requires_redirect?
    unpublished? || publication_has_been_published?
  end

  def can_be_tagged_to_taxonomy?
    organisations_content_ids = organisations.map(&:content_id)

    organisations_in_education_tagging_beta?(organisations_content_ids)
  end

private

  def organisations_in_education_tagging_beta?(org_content_ids)
    (org_content_ids & Whitehall.organisations_in_tagging_beta).present?
  end

  def publication_has_been_published?
    publication && publication.published?
  end

  def publication_url
    Whitehall.url_maker.public_document_path(publication)
  end

  def last_major_change
    statistics_announcement_dates.
      where('change_note IS NOT NULL && change_note != ?', '').
      order(:created_at).
      last
  end

  def publication_is_matching_type
    unless publication.publication_type == publication_type
      errors[:publication] << "type does not match: must be #{type_string}"
    end
  end

  def type_string
    national_statistic? ? 'national statistics' : 'statistics'
  end

  def redirect_not_circular
    if redirect_url.present?
      if public_path == redirect_url
        errors.add(:redirect_url, "cannot redirect to itself")
      end
    end
  end

  def publish_redirect_to_publication
    Whitehall::PublishingApi.publish_redirect_async(content_id, publication_url)
  end

  def publish_redirect_to_redirect_url
    Whitehall::PublishingApi.publish_redirect_async(content_id, redirect_url)
  end
end
