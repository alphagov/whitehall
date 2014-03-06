class StatisticalReleaseAnnouncement < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title

  belongs_to :creator, class_name: 'User'
  belongs_to :organisation
  belongs_to :topic

  validates :title, :summary, :expected_release_date, :organisation, :topic, :creator, presence: true
  validates :publication_type_id,
              inclusion: {
                in: PublicationType.statistical.map(&:id),
                message: 'must be a statistical type'
              }

  include Searchable
  searchable  title: :title,
              link: :public_path,
              description: :summary,
              slug: :slug,
              organisations: :organisation_slugs,
              topics: :topic_slugs,
              expected_release_timestamp: :expected_release_date,
              expected_release_text: :display_release_date

  def display_release_date
    if display_release_date_override.blank?
      expected_release_date.to_s(:long_ordinal)
    else
      display_release_date_override
    end
  end

  def publication_type
    PublicationType.find_by_id(publication_type_id)
  end

  def public_path
    Whitehall.url_maker.statistical_release_announcement_path(self)
  end

  def organisation_slugs
    [organisation.slug]
  end

  def topic_slugs
    [topic.slug]
  end
end
