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

    after_save :copy_inherited_associations_to_children, if: :is_parent_document?
  end

  def is_parent_document?
    children.any?
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

  def requires_taxon?
    return false if is_child_document?

    super
  end

  def copy_inherited_associations_to_children
    children.each do |child|
      # TODO: have this driven by `associations.inherited` in the document type definition
      # TODO: find a better way of scaling more associations that need to be copied
      edition_organisations.each do |association|
        # TODO: find a more efficient way of updating child associations without having to delete and re-create them all
        child.edition_organisations.delete_all
        child.edition_organisations.build(association.attributes.except("id"))
      end
      child.save!
    end
  end
end
