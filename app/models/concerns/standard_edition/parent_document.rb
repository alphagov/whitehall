module StandardEdition::ParentDocument
  extend ActiveSupport::Concern

  included do
    has_many :child_relationships,
             class_name: "ParentChildRelationship",
             foreign_key: :parent_edition_id
    has_many :child_documents, through: :child_relationships, source: :child_document
  end

  def child_editions
    Edition.where(id: child_documents.select(:latest_edition_id))
  end

  def can_create_new_child_documents?
    allows_child_documents? && pre_publication?
  end

  def has_published_or_scheduled_children?
    all_editions_of_child_documents.where(state: %w[published scheduled]).exists?
  end

private

  def all_editions_of_child_documents
    Edition.where(document_id: ParentChildRelationship.where(parent_edition: document.editions).select(:child_document_id))
  end
end
