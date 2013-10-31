module Edition::RelatedDocuments
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      edition.related_documents = @edition.related_documents
    end
  end

  included do
    has_many :outbound_edition_relations, foreign_key: :edition_id, dependent: :destroy, class_name: 'EditionRelation'
    has_many :related_documents, through: :outbound_edition_relations, source: :document
    has_many :related_to_editions, through: :related_documents, source: :editions

    add_trait Trait
  end

  def related_editions=(editions)
    self.related_documents = editions.map(&:document)
  end
end
