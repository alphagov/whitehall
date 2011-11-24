class Publication < Document
  include Document::NationalApplicability
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedDocuments
  include Document::Attachable

  has_one :publication_metadatum

  validates :publication_metadatum, presence: true

  accepts_nested_attributes_for :publication_metadatum

  class Trait < Document::Traits::Trait
    def process_associations_before_save(document)
      document.build_publication_metadatum(@document.publication_metadatum.attributes.except(:id))
    end
  end

  add_trait Trait
end