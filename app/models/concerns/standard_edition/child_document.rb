module StandardEdition::ChildDocument
  extend ActiveSupport::Concern

  included do
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

  def requires_taxon?
    return false if is_child_document?

    super
  end

  def child_document_base_path_override
    if is_child_document?
      parent_path = parent_edition.base_path
      fixed_path = type_instance.settings["fixed_path"]
      fixed_path.sub("$INHERITED", parent_path)
    end
  end
end
