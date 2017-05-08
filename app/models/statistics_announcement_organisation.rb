class StatisticsAnnouncementOrganisation < ApplicationRecord
  belongs_to :statistics_announcement, inverse_of: :statistics_announcement_organisations
  belongs_to :organisation, inverse_of: :statistics_announcement_organisations

  validates :statistics_announcement, :organisation, presence: true
end
