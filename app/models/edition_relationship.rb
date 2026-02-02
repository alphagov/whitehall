# Used for Parent/Child edition associations
class EditionRelationship < ApplicationRecord
  belongs_to :parent_edition, class_name: "Edition"
  belongs_to :child_edition,  class_name: "Edition"

  validate :not_self

  after_create :inherit_from_parent!

private

  def not_self
    errors.add(:child_edition, "cannot equal parent") if parent_edition_id == child_edition_id
  end

  def inherit_from_parent!
    child_edition.with_lock do
      child_edition.inherit_associations_from_parent(parent_edition)
    end
  end
end
