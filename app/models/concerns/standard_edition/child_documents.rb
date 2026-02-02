module StandardEdition::ChildDocuments
  extend ActiveSupport::Concern

  included do
    has_many :child_relationships,
             class_name: "EditionRelationship",
             foreign_key: :parent_edition_id,
             inverse_of: :parent_edition,
             dependent: :destroy

    has_many :children,
             through: :child_relationships,
             source: :child_edition

    has_one :parent_relationship,
            class_name: "EditionRelationship",
            foreign_key: :child_edition_id,
            inverse_of: :child_edition,
            dependent: :restrict_with_error

    has_one :parent_edition,
            through: :parent_relationship,
            source: :parent_edition
  end

  def is_child_document?
    parent_edition.present?
  end

  def child_document_base_path_override
    if is_child_document?
      parent_path = parent_edition.base_path
      fixed_path = type_instance.settings["fixed_path"]
      fixed_path.sub("$INHERITED", parent_path)
    end
  end

  def allows_child_documents?
    type_instance.child_documents
  end

  def child_documents
    rels = child_relationships.order(:position)
    Edition.where(id: rels.select(:child_edition_id))
  end
end
