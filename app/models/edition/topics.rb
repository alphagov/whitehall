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
end
