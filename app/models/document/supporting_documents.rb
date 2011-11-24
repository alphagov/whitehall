module Document::SupportingDocuments
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def process_associations_after_save(document)
      @document.supporting_documents.each do |sd|
        document.supporting_documents.create(sd.attributes.except("document_id"))
      end
    end
  end

  included do
    has_many :supporting_documents, foreign_key: :document_id

    add_trait Trait
  end

  def allows_supporting_documents?
    true
  end

  def has_supporting_documents?
    supporting_documents.any?
  end
end