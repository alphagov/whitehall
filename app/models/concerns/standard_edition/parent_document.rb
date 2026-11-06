module StandardEdition::ParentDocument
  extend ActiveSupport::Concern

  included do
    has_many :child_relationships,
             class_name: "ParentChildRelationship",
             foreign_key: :parent_edition_id
    has_many :child_documents, through: :child_relationships, source: :child_document

    after_commit :republish_child_documents, if: -> { saved_change_to_slug || saved_change_to_state? }
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

  def has_publicly_visible_or_scheduled_children?
    all_editions_of_child_documents.where(state: %w[published withdrawn scheduled]).exists?
  end

private

  def republish_child_documents
    child_document_ids = ParentChildRelationship.where(parent_edition_id: id).select(:child_document_id)
    Document.where(id: child_document_ids).find_each do |document|
      Whitehall::PublishingApi.republish_document_async(document)
    end
  end

  def all_editions_of_child_documents
    Edition.where(document_id: ParentChildRelationship.where(parent_edition: document.editions).select(:child_document_id))
  end
end
