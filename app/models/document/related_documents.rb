module Document::RelatedDocuments
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def copy_associations_to(document)
      document.documents_related_with = @document.documents_related_with
      document.documents_related_to = @document.documents_related_to
    end
  end

  included do
    has_many :document_relations_to, class_name: "DocumentRelation", foreign_key: "document_id"
    has_many :document_relations_from, class_name: "DocumentRelation", foreign_key: "related_document_id"

    has_many :documents_related_with, through: :document_relations_to, source: :related_document
    has_many :documents_related_to, through: :document_relations_from, source: :document

    has_many :published_documents_related_with, through: :document_relations_to, source: :related_document, conditions: { "documents.state" => "published" }
    has_many :published_documents_related_to, through: :document_relations_from, source: :document, conditions: { "documents.state" => "published" }

    add_trait Trait
  end

  def can_be_related_to_other_documents?
    true
  end

  def related_documents
    [*documents_related_to, *documents_related_with].uniq
  end

  def published_related_documents
    [*published_documents_related_to, *published_documents_related_with].uniq
  end
end