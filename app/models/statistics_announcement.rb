class StatisticsAnnouncement < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title

  belongs_to :creator, class_name: 'User'
  belongs_to :cancelled_by, class_name: 'User'
  belongs_to :publication

  has_one  :current_release_date,
    -> { order('created_at DESC') },
    class_name: 'StatisticsAnnouncementDate',
    inverse_of: :statistics_announcement
  has_many :statistics_announcement_dates, dependent: :destroy

  has_many :statistics_announcement_topics, inverse_of: :statistics_announcement, dependent: :destroy
  has_many :topics, through: :statistics_announcement_topics

  has_many :statistics_announcement_organisations, inverse_of: :statistics_announcement, dependent: :destroy
  has_many :organisations, through: :statistics_announcement_organisations

  validate  :publication_is_matching_type, if: :publication
  validates :title, :summary, :organisations, :topics, :creator, :current_release_date, presence: true
  validates :cancellation_reason, presence: {  message: "must be provided when cancelling an announcement" }, if: :cancelled?
  validates :publication_type_id,
              inclusion: {
                in: PublicationType.statistical.map(&:id),
                message: 'must be a statistical type'
              }

  accepts_nested_attributes_for :current_release_date, reject_if: :persisted?

  scope :with_title_containing, -> *keywords {
    pattern = "(#{keywords.map { |k| Regexp.escape(k) }.join('|')})"
    where("statistics_announcements.title REGEXP :pattern OR statistics_announcements.slug = :slug", pattern: pattern, slug: keywords)
  }
  scope :in_organisations, Proc.new { |organisation_ids| joins(:statistics_announcement_organisations)
    .where(statistics_announcement_organisations: { organisation_id: organisation_ids })
  }

  include Searchable
  searchable  only: :without_published_publication,
              title: :title,
              link: :public_path,
              description: :summary,
              display_type: :display_type,
              slug: :slug,
              organisations: :organisations_slugs,
              topics: :topic_slugs,
              release_timestamp: :release_date,
              statistics_announcement_state: :state,
              metadata: :search_metadata

  delegate  :release_date, :display_date, :confirmed?,
              to: :current_release_date, allow_nil: true


  def self.without_published_publication
    includes(:publication).
      references(:editions).
      where("publication_id IS NULL || editions.state NOT IN (?)", Edition::POST_PUBLICATION_STATES)
  end

  def self.with_topics(topic_ids)
    joins(:statistics_announcement_topics).
    where(statistics_announcement_topics: { topic_id: topic_ids})
  end

  def last_change_note
    last_major_change.try(:change_note)
  end

  def previous_display_date
    if last_major_change
      major_change_index = statistics_announcement_dates.index(last_major_change)
      statistics_announcement_dates.at(major_change_index - 1).try(:display_date)
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

  def organisations_slugs
    organisations.map(&:slug)
  end

  def topic_slugs
    topics.map(&:slug)
  end

  def search_metadata
    { confirmed: confirmed?,
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

private

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
end
