module StandardEdition::ParentDocument
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(new_edition)
      ParentChildRelationship
        .where(parent_edition_id: @edition.id)
        .find_each do |relationship|
        ParentChildRelationship.create!(
          parent_edition_id: new_edition.id,
          child_document_id: relationship.child_document_id,
        )
      end
    end
  end

  included do
    has_many :child_relationships,
             class_name: "ParentChildRelationship",
             foreign_key: :parent_edition_id,
             inverse_of: :parent_edition,
             dependent: :destroy

    has_many :child_documents,
             through: :child_relationships,
             source: :child_document

    add_trait Trait
  end

  def allows_child_documents?
    (type_instance.settings["allowed_child_document_types"] || []).count.positive?
  end

  def is_parent_document?
    child_documents.any?
  end

  def child_editions
    Edition.where(id: child_documents.select(:latest_edition_id))
  end

  def new_child_documents
    child_documents.where(live_edition_id: nil)
  end
end
