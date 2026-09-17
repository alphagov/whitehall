module StandardEdition::ChildDocument
  extend ActiveSupport::Concern

  included do
    has_one :parent_relationship,
            class_name: "ParentChildRelationship",
            foreign_key: :child_document_id,
            primary_key: :document_id
    has_one :parent_edition, through: :parent_relationship
  end
end
