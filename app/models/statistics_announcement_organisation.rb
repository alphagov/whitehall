class StatisticsAnnouncementOrganisation < ActiveRecord::Base
  belongs_to :statistics_announcement
  belongs_to :organisation

  validates :statistics_announcement, :organisation, presence: true
end
