class Topic < Classification
  has_many :featured_links, as: :linkable, dependent: :destroy, order: :created_at
  accepts_nested_attributes_for :featured_links, reject_if: -> attributes { attributes['url'].blank? }, allow_destroy: true
  has_many :statistics_announcement_topics

  def self.with_statistics_announcements
    joins(:statistics_announcement_topics)
      .group('statistics_announcement_topics.topic_id')
  end
end
