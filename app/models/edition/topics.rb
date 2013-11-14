module Edition::Topics
  extend ActiveSupport::Concern
  include Edition::Classifications

  included do
    has_many :topics, through: :classification_memberships, source: :topic
    has_one :topic_suggestion, foreign_key: :edition_id
  end

  def can_be_associated_with_topics?
    true
  end

  def search_index
    super.merge("topics" => topics.map(&:slug)) { |k, ov, nv| ov + nv }
  end

  module ClassMethods
    def in_topic(topic)
      joins(:classification_memberships).where("classification_memberships.classification_id" => topic)
    end

    def published_in_topic(topic)
      published.in_topic(topic)
    end

    def scheduled_in_topic(topic)
      scheduled.in_topic(topic)
    end
  end
end
