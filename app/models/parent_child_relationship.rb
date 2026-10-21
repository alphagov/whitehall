class ParentChildRelationship < ApplicationRecord
  validate :parent_edition_must_be_in_prepublication_state, on: :create

  belongs_to :parent_edition,
             class_name: "Edition"

  belongs_to :child_document,
             class_name: "Document"

  validates :parent_edition_id, presence: true

  # we can't validate presence of child_document_id
  # as we build the relationship before the child document
  # has been saved (and we don't want to save the document
  # if it results in an invalid relationship).

private

  def parent_edition_must_be_in_prepublication_state
    return if parent_edition.blank?

    return if parent_edition.pre_publication?

    errors.add(:parent_edition_id, "must be in a draft state in order to create a child page")
  end
end
