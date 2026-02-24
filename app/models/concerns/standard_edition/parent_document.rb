module StandardEdition::ParentDocument
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(new_edition)
      EditionRelationship.where(parent_edition_id: @edition.id).each do |relationship|
        EditionRelationship.create(parent_edition_id: new_edition.id, child_edition_id: relationship.child_edition_id, position: relationship.position)
      end
    end
  end

  included do
    has_many :child_relationships,
             class_name: "EditionRelationship",
             foreign_key: :parent_edition_id,
             inverse_of: :parent_edition,
             dependent: :destroy

    has_many :children,
             through: :child_relationships,
             source: :child_edition

    after_save :copy_inherited_associations_to_children, if: :is_parent_document?

    add_trait Trait
  end

  def is_parent_document?
    children.any?
  end

  def allows_child_documents?
    type_instance.child_documents
  end

  def child_documents
    rels = child_relationships.order(:position)
    Edition.where(id: rels.select(:child_edition_id))
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
