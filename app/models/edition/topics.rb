module Edition::Topics
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.topic_memberships = @edition.topic_memberships.map do |dt|
        TopicMembership.new(dt.attributes.except(:id))
      end
    end
  end

  included do
    has_many :topic_memberships, dependent: :destroy
    has_many :topics, through: :topic_memberships

    add_trait Trait
  end

  def can_be_associated_with_topics?
    true
  end

  module ClassMethods
    def in_topic(topic)
      joins(:topics).where('topics.id' => topic)
    end
  end
end