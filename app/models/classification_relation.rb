class ClassificationRelation < ActiveRecord::Base
  belongs_to :classification
  belongs_to :related_classification, foreign_key: :related_classification_id, class_name: "Classification"
  belongs_to :topic, foreign_key: :classification_id, class_name: "Topic"
  belongs_to :related_topic, foreign_key: :related_classification_id, class_name: "Topic"

  validates :classification_id, presence: true
  validates :related_classification_id, presence: true
  validates :classification_id, uniqueness: { scope: :related_classification_id }

  class Validator < ActiveModel::Validator
    def validate(record)
      if record && record.classification_id && record.classification_id == record.related_classification_id
        record.errors[:classification] = "cannot relate to itself"
      end
    end
  end

  validates_with Validator

  after_create :create_inverse_relation
  after_destroy :destroy_inverse_relation

  def self.relation_for(classification_id, related_classification_id)
    where(classification_id: classification_id, related_classification_id: related_classification_id).first
  end

  def inverse_relation
    self.class.relation_for(related_classification_id, classification_id)
  end

  def create_inverse_relation
    unless inverse_relation.present?
      self.class.create!(
        classification_id: related_classification_id,
        related_classification_id: classification_id
      )
    end
  end

  def destroy_inverse_relation
    if inverse_relation.present?
      inverse_relation.destroy
    end
  end
end
