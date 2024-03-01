module Edition::EditionableWorldwideOrganisations
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.editionable_worldwide_organisation_documents = @edition.editionable_worldwide_organisation_documents
    end
  end

  included do
    has_many :edition_editionable_worldwide_organisations, foreign_key: :edition_id, dependent: :destroy
    has_many :editionable_worldwide_organisation_documents, through: :edition_editionable_worldwide_organisations, source: :document
    has_many :editionable_worldwide_organisations, through: :editionable_worldwide_organisation_documents, source: :latest_edition
    has_many :published_editionable_worldwide_organisations, through: :editionable_worldwide_organisation_documents, source: :live_edition, class_name: "EditionableWorldwideOrganisation"

    add_trait Trait
  end

  def editionable_worldwide_organisations=(editionable_worldwide_organisations)
    self.editionable_worldwide_organisation_documents = editionable_worldwide_organisations.map(&:document)
  end
end
