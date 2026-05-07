module StandardEdition::ParentDocument
  extend ActiveSupport::Concern

  included do
    has_many :child_relationships,
             class_name: "ParentChildRelationship",
             foreign_key: :parent_edition_id,
             inverse_of: :parent_edition,
             dependent: :destroy

    has_many :child_documents,
             through: :child_relationships,
             source: :child_document
  end

  def is_parent_document?
    child_documents.any?
  end

  def child_editions
    child_documents.includes(:latest_edition).map(&:latest_edition)
  end
end
