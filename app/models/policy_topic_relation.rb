class PolicyTopicRelation < ActiveRecord::Base
  belongs_to :policy_topic
  belongs_to :related_policy_topic, class_name: "PolicyTopic"

  validates :policy_topic_id, presence: true
  validates :related_policy_topic_id, presence: true
  validates :policy_topic_id, uniqueness: { scope: :related_policy_topic_id }

  class Validator < ActiveModel::Validator
    def validate(record)
      if record && record.policy_topic_id && record.policy_topic_id == record.related_policy_topic_id
        record.errors[:policy_topic] = "cannot relate to itself"
      end
    end
  end

  validates_with Validator

  after_create :create_inverse_relation
  after_destroy :destroy_inverse_relation

  class << self
    def relation_for(policy_topic_id, related_policy_topic_id)
      where(policy_topic_id: policy_topic_id, related_policy_topic_id: related_policy_topic_id).first
    end
  end

  def inverse_relation
    self.class.relation_for(related_policy_topic_id, policy_topic_id)
  end

  def readonly?
    !new_record?
  end

  def create_inverse_relation
    unless inverse_relation.present?
      self.class.create!(
        policy_topic_id: related_policy_topic_id,
        related_policy_topic_id: policy_topic_id
      )
    end
  end

  def destroy_inverse_relation
    if inverse_relation.present?
      inverse_relation.destroy
    end
  end
end
