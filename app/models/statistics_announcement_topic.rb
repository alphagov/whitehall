class StatisticsAnnouncementTopic < ActiveRecord::Base
  belongs_to :statistics_announcement
  belongs_to :topic

  validates :statistics_announcement, :topic, presence: true
end
