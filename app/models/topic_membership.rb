class TopicMembership < ActiveRecord::Base
  belongs_to :edition
  belongs_to :topic
  belongs_to :policy, foreign_key: :edition_id
  belongs_to :detailed_guide, foreign_key: :edition_id

  validates :edition, :topic, presence: true

  default_scope order("topic_memberships.ordering ASC")

  after_create :update_topic_counts
  after_destroy :update_topic_counts

  class << self
    def published
      joins(:edition).where("editions.state" => "published")
    end

    def for_type(type)
      joins(:edition).where("editions.type" => type)
    end
  end

  private

  def update_topic_counts
    topic.update_counts
  end
end
