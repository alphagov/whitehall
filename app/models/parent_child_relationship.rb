class ParentChildRelationship < ApplicationRecord
  validate :parent_edition_must_be_in_prepublication_state, on: :create
  validate :only_descended_from_one_parent, on: :create

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

  def only_descended_from_one_parent
    return if child_document.blank?

    relationship_records = ParentChildRelationship.where(child_document_id: child_document.id)
    parent_document_ids = Edition.where(id: relationship_records.pluck(:parent_edition_id)).pluck(:document_id).compact.uniq

    return if parent_document_ids.empty? || # newly created document will have no prior parent relationships
      parent_document_ids == [parent_edition.document.id] # check all related parent document ids are the same

    errors.add(:parent_edition_id, "must have the same document as previous parent edition")
  end
end
