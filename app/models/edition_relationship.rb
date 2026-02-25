# Used for Parent/Child edition associations
class EditionRelationship < ApplicationRecord
  belongs_to :parent_edition, class_name: "Edition"
  belongs_to :child_document, class_name: "Document"
end
