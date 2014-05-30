class StatisticsAnnouncement < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title

  belongs_to :creator, class_name: 'User'
  belongs_to :organisation
  belongs_to :topic
  belongs_to :publication

  has_one  :current_release_date, class_name: 'StatisticsAnnouncementDate', order: 'created_at DESC', inverse_of: :statistics_announcement
  has_many :statistics_announcement_dates

  validate  :publication_is_matching_type, if: :publication
  validates :title, :summary, :organisation, :topic, :creator, :current_release_date, presence: true
  validates :publication_type_id,
              inclusion: {
                in: PublicationType.statistical.map(&:id),
                message: 'must be a statistical type'
              }

  accepts_nested_attributes_for :current_release_date, reject_if: :persisted?

  include Searchable
  searchable  title: :title,
              link: :public_path,
              description: :summary,
              display_type: :display_type,
              slug: :slug,
              organisations: :organisation_slugs,
              topics: :topic_slugs,
              release_timestamp: :release_date,
              metadata: :search_metadata

  delegate  :release_date, :display_date, :confirmed?,
              to: :current_release_date

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

  def organisation_slugs
    [organisation.slug]
  end

  def topic_slugs
    [topic.slug]
  end

  def search_metadata
    { confirmed: confirmed?,
      display_date: display_date,
      change_note: last_change_note,
      previous_display_date: previous_display_date }
  end

  def build_statistics_announcement_date_change(attributes = {})
    current_date_attributes = current_release_date.attributes.slice('release_date', 'confirmed', 'precision')

    StatisticsAnnouncementDateChange.new(attributes.reverse_merge(current_date_attributes)) do |change|
      change.statistics_announcement = self
      change.current_release_date = current_release_date
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
    publication_type == PublicationType::NationalStatistics ? 'national statistics' : 'statistics'
  end
end
