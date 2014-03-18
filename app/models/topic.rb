class Topic < Classification
  include HasTopTasks

  scope :with_statistical_release_announcements, -> { joins("INNER JOIN statistical_release_announcements ON statistical_release_announcements.topic_id = classifications.id").group("classifications.id") }
end
