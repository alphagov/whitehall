class TopicMembership < ActiveRecord::Base
  belongs_to :edition
  belongs_to :topic
  belongs_to :policy, foreign_key: :edition_id
  belongs_to :specialist_guide, foreign_key: :edition_id

  validates :edition, :topic, presence: true

  default_scope order("topic_memberships.ordering ASC")

  scope :featured, where(featured: true)

  class << self
    def published
      joins(:edition).where("editions.state" => "published")
    end

    def for_type(type)
      joins(:edition).where("editions.type" => type)
    end
  end
end
