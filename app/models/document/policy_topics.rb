module Document::PolicyTopics
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def process_associations_before_save(document)
      document.policy_topic_memberships = @document.policy_topic_memberships.map do |dt|
        PolicyTopicMembership.new(dt.attributes.except(:id))
      end
    end
  end

  included do
    has_many :policy_topic_memberships, dependent: :destroy
    has_many :policy_topics, through: :policy_topic_memberships

    add_trait Trait
  end

  def can_be_associated_with_policy_topics?
    true
  end

  module ClassMethods
    def in_policy_topic(policy_topic)
      joins(:policy_topics).where('policy_topics.id' => policy_topic)
    end
  end
end