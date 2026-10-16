class ParentChildRelationship < ApplicationRecord
  validate :parent_edition_must_be_in_prepublication_state, on: :create

  belongs_to :parent_edition,
             class_name: "Edition"

  belongs_to :child_document,
             class_name: "Document"

private

  def parent_edition_must_be_in_prepublication_state
    return if parent_edition.blank?

    return if parent_edition.pre_publication?

    errors.add(:parent_edition_id, "must be in a draft state in order to create a child page")
  end
end
