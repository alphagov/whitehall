module Document::RelatedDocuments
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def process_associations_after_save(document)
      document.related_documents = @document.related_documents
    end
  end

  DESTROY_INVERSE_RELATION = -> d, rd { DocumentRelation.relation_for(d.id, rd.id).destroy_inverse_relation }

  included do
    has_many :document_relations, class_name: "DocumentRelation", foreign_key: "document_id"
    has_many :related_documents, through: :document_relations, before_remove: DESTROY_INVERSE_RELATION
    has_many :published_related_documents, through: :document_relations, source: :related_document, conditions: { "documents.state" => "published" }, before_remove: DESTROY_INVERSE_RELATION

    add_trait Trait
  end

  def can_be_related_to_other_documents?
    true
  end
end
