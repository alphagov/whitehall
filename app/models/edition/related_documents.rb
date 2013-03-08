module Edition::RelatedDocuments
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      edition.related_documents = @edition.related_documents
    end
  end

  included do
    has_many :edition_relations, foreign_key: :edition_id, dependent: :destroy
    has_many :related_documents, through: :edition_relations, source: :document

    define_method(:related_editions=) do |editions|
      self.related_documents = editions.map(&:document)
    end

    add_trait Trait
  end
end
