class TopicMembership < ActiveRecord::Base
  belongs_to :policy
  belongs_to :topic

  validates :policy, :topic, presence: true

  default_scope order("topic_memberships.ordering ASC")

  class << self
    def published
      joins(:policy).where("editions.state" => "published")
    end

    def for_type(type)
      joins(:policy).where("editions.type" => type)
    end
  end
end