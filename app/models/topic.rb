class Topic < Classification
  include HasTopTasks

  scope :with_statistics_announcements, -> { joins("INNER JOIN statistics_announcements ON statistics_announcements.topic_id = classifications.id").group("classifications.id") }
end
