class PolicyAreaRelation < ActiveRecord::Base
  belongs_to :policy_area
  belongs_to :related_policy_area, class_name: "PolicyArea"

  validates :policy_area_id, presence: true
  validates :related_policy_area_id, presence: true
  validates :policy_area_id, uniqueness: { scope: :related_policy_area_id }

  class Validator < ActiveModel::Validator
    def validate(record)
      if record && record.policy_area_id && record.policy_area_id == record.related_policy_area_id
        record.errors[:policy_area] = "cannot relate to itself"
      end
    end
  end

  validates_with Validator

  after_create :create_inverse_relation
  after_destroy :destroy_inverse_relation

  scope :inverse_relations_for, -> relation {
    where(
      policy_area_id: relation.related_policy_area_id,
      related_policy_area_id: relation.policy_area_id
    )
  }

  def inverse_relation
    self.class.inverse_relations_for(self).first
  end

  def readonly?
    !new_record?
  end

  private

  def create_inverse_relation
    unless inverse_relation.present?
      self.class.create!(
        policy_area_id: related_policy_area_id,
        related_policy_area_id: policy_area_id
      )
    end
  end

  def destroy_inverse_relation
    if inverse_relation.present?
      inverse_relation.destroy
    end
  end
end
