module Document::RelatedDocuments
  extend ActiveSupport::Concern

  included do
    has_many :document_relations_to, class_name: "DocumentRelation", foreign_key: "document_id"
    has_many :document_relations_from, class_name: "DocumentRelation", foreign_key: "related_document_id"

    has_many :documents_related_with, through: :document_relations_to, source: :related_document
    has_many :documents_related_to, through: :document_relations_from, source: :document
  end

  def can_be_related_to_other_documents?
    true
  end

  def related_documents
    [*documents_related_to, *documents_related_with].uniq
  end
end