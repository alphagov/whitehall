module StandardEdition::ChildDocument
  extend ActiveSupport::Concern

  included do
    has_one :parent_relationship,
            class_name: "ParentChildRelationship",
            foreign_key: :child_document_id,
            primary_key: :document_id,
            inverse_of: :child_document

    has_one :parent_edition,
            through: :parent_relationship,
            source: :parent_edition
  end

  def is_child_document?
    parent_edition.present?
  end
end
