class StatisticsAnnouncement < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title

  belongs_to :creator, class_name: 'User'
  belongs_to :organisation
  belongs_to :topic
  belongs_to :publication

  has_one  :statistics_announcement_date, inverse_of: :statistics_announcement

  validate  :publication_is_statistics, if: :publication
  validates :title, :summary, :organisation, :topic, :creator, :statistics_announcement_date, presence: true
  validates :publication_type_id,
              inclusion: {
                in: PublicationType.statistical.map(&:id),
                message: 'must be a statistical type'
              }

  accepts_nested_attributes_for :statistics_announcement_date

  include Searchable
  searchable  title: :title,
              link: :public_path,
              description: :summary,
              display_type: :display_type,
              slug: :slug,
              organisations: :organisation_slugs,
              topics: :topic_slugs,
              expected_release_timestamp: :release_date,
              expected_release_text: :display_date

  delegate :release_date, :display_date, to: :statistics_announcement_date

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

private

  def publication_is_statistics
    errors[:publication] << "must be statistics" unless publication.statistics?
  end
end
