module Edition::Topics
  extend ActiveSupport::Concern
  include Edition::Classifications

  included do
    has_many :topics, through: :classification_memberships, source: :topic
    after_update :update_topic_counts
  end

  def can_be_associated_with_topics?
    true
  end

  def update_topic_counts
    topics.each(&:update_counts)
    true
  end

  def search_index
    super.merge("topics" => topics.map(&:slug)) { |k, ov, nv| ov + nv }
  end

  module ClassMethods
    def in_topic(topic)
      joins(:topics).where('classifications.id' => topic)
    end

    def published_in_topic(topic)
      published.in_topic(topic)
    end

    def scheduled_in_topic(topic)
      scheduled.in_topic(topic)
    end
  end
end
