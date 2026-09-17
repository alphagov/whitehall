class ParentChildRelationship < ApplicationRecord
  belongs_to :parent_edition,
             class_name: "Edition"

  belongs_to :child_document,
             class_name: "Document"
end
