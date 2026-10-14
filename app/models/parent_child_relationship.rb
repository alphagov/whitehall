class ParentChildRelationship < ApplicationRecord
  validate :only_descended_from_one_parent, on: :create

  belongs_to :parent_edition,
             class_name: "Edition"

  belongs_to :child_document,
             class_name: "Document"

private

  def only_descended_from_one_parent
    return if child_document.blank?

    relationships = ParentChildRelationship.where(child_document_id: child_document.id)

    return if relationships.empty?

    documents = relationships.map(&:parent_edition).compact.map(&:document)

    return if documents.empty?

    document_ids = documents.map(&:id)

    return if document_ids.concat([parent_edition.document.id]).reduce(&:eql?)

    errors.add(:parent_edition_id, "must have the same document as previous parent edition")
  end
end
