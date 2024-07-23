module Edition::WorldwideOrganisations
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.worldwide_organisation_documents = @edition.worldwide_organisation_documents
    end
  end

  included do
    has_many :edition_worldwide_organisations, foreign_key: :edition_id, dependent: :destroy
    has_many :worldwide_organisation_documents, through: :edition_worldwide_organisations, source: :document
    has_many :worldwide_organisations, through: :worldwide_organisation_documents, source: :latest_edition
    has_many :published_worldwide_organisations, through: :worldwide_organisation_documents, source: :live_edition, class_name: "WorldwideOrganisation"

    add_trait Trait

    validate :at_least_one_worldwide_organisation
  end

  def worldwide_organisations=(worldwide_organisations)
    self.worldwide_organisation_documents = worldwide_organisations.map(&:document)
  end

  def can_be_associated_with_worldwide_organisations?
    true
  end

  def skip_worldwide_organisations_validation?
    true
  end

  def at_least_one_worldwide_organisation
    return if skip_worldwide_organisations_validation?

    errors.add(:worldwide_organisations, "at least one required") if worldwide_organisation_document_ids.empty?
  end
end
