module Document::RelatedDocuments
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def process_associations_after_save(document)
      document.related_documents = @document.related_documents
    end
  end

  included do
    has_many :document_relations, class_name: "DocumentRelation", foreign_key: "document_id"
    has_many :related_documents, through: :document_relations, before_remove: -> d, rd {
      DocumentRelation.relation_for(d, rd).destroy_inverse_relation
    }
    has_many :published_related_documents, through: :document_relations, source: :related_document, conditions: { "documents.state" => "published" }

    alias :documents_related_to :related_documents
    alias :documents_related_with :related_documents

    alias :documents_related_to= :related_documents=
    alias :documents_related_with= :related_documents=

    add_trait Trait
  end

  def can_be_related_to_other_documents?
    true
  end
end