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

    validate :at_least_one_editionable_worldwide_organisation
  end

  def editionable_worldwide_organisations=(editionable_worldwide_organisations)
    self.editionable_worldwide_organisation_documents = editionable_worldwide_organisations.map(&:document)
  end

  def can_be_associated_with_worldwide_organisations?
    true
  end

  def skip_worldwide_organisations_validation?
    true
  end

  def at_least_one_editionable_worldwide_organisation
    return unless Flipflop.editionable_worldwide_organisations? && !skip_worldwide_organisations_validation?

    errors.add(:editionable_worldwide_organisations, "at least one required") if editionable_worldwide_organisation_document_ids.empty?
  end
end
