class Topic < Classification
  include HasFeaturedLinks
  has_featured_links :top_tasks
  has_many :statistics_announcement_topics

  def self.with_statistics_announcements
    joins(:statistics_announcement_topics)
      .group('statistics_announcement_topics.topic_id')
  end
end
