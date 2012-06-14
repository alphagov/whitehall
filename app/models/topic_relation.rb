class TopicRelation < ActiveRecord::Base
  belongs_to :topic
  belongs_to :related_topic, class_name: "Topic"

  validates :topic_id, presence: true
  validates :related_topic_id, presence: true
  validates :topic_id, uniqueness: { scope: :related_topic_id }

  class Validator < ActiveModel::Validator
    def validate(record)
      if record && record.topic_id && record.topic_id == record.related_topic_id
        record.errors[:topic] = "cannot relate to itself"
      end
    end
  end

  validates_with Validator

  after_create :create_inverse_relation
  after_destroy :destroy_inverse_relation

  class << self
    def relation_for(topic_id, related_topic_id)
      where(topic_id: topic_id, related_topic_id: related_topic_id).first
    end
  end

  def inverse_relation
    self.class.relation_for(related_topic_id, topic_id)
  end

  def readonly?
    !new_record?
  end

  def create_inverse_relation
    unless inverse_relation.present?
      self.class.create!(
        topic_id: related_topic_id,
        related_topic_id: topic_id
      )
    end
  end

  def destroy_inverse_relation
    if inverse_relation.present?
      inverse_relation.destroy
    end
  end
end
