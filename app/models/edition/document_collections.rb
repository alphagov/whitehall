module Edition::DocumentCollections
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.document_collections = @edition.document_collections
    end
  end

  included do
    has_many :edition_document_collections, foreign_key: :edition_id, dependent: :destroy
    has_many :document_collections, through: :edition_document_collections

    add_trait Trait
  end
end
