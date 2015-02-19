class StatisticsAnnouncementTopic < ActiveRecord::Base
  belongs_to :statistics_announcement, inverse_of: :statistics_announcement_topics
  belongs_to :topic, inverse_of: :statistics_announcement_topics

  validates :statistics_announcement, :topic, presence: true
end
