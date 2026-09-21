module StandardEdition::ParentDocument
  extend ActiveSupport::Concern

  included do
    has_many :child_relationships,
             class_name: "ParentChildRelationship",
             foreign_key: :parent_edition_id
    has_many :child_documents, through: :child_relationships, source: :child_document
  end
end
