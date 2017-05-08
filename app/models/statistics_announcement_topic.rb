class StatisticsAnnouncementTopic < ApplicationRecord
  belongs_to :statistics_announcement, inverse_of: :statistics_announcement_topics

  # DID YOU MEAN: Policy Area?
  # "Policy area" is the newer name for "topic"
  # (https://www.gov.uk/government/topics)
  # "Topic" is the newer name for "specialist sector"
  # (https://www.gov.uk/topic)
  # You can help improve this code by renaming all usages of this field to use
  # the new terminology.
  belongs_to :topic, inverse_of: :statistics_announcement_topics

  validates :statistics_announcement, :topic, presence: true
end
