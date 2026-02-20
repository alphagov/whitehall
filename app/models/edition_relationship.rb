# Used for Parent/Child edition associations
class EditionRelationship < ApplicationRecord
  belongs_to :parent_edition, class_name: "Edition"
  belongs_to :child_edition,  class_name: "Edition"

  validate :not_self

private

  def not_self
    errors.add(:child_edition, "cannot equal parent") if parent_edition_id == child_edition_id
  end
end
