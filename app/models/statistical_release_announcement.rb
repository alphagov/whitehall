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

  def publication_type
    PublicationType.find_by_id(publication_type_id)
  end
end
