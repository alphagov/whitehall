class ParentChildRelationship < ApplicationRecord
  belongs_to :parent_edition,
             class_name: "Edition"

  belongs_to :child_document,
             class_name: "Document"

  validates :parent_edition_id, presence: true

  # we can't validate presence of child_document_id
  # as we build the relationship before the child document
  # has been saved (and we don't want to save the document
  # if it results in an invalid relationship).
end
