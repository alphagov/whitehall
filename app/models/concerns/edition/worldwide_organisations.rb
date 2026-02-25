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

    validate :at_least_one_worldwide_organisation, if: :worldwide_organisation_association_required?
  end

  def worldwide_organisations=(worldwide_organisations)
    self.worldwide_organisation_documents = worldwide_organisations.map(&:document)
  end

  def worldwide_organisation_association_required?
    false
  end

  def at_least_one_worldwide_organisation
    if worldwide_organisation_document_ids.empty?
      errors.add(:worldwide_organisation_document_ids, "at least one required")
    end
  end

  def error_labels
    super.merge({ "worldwide_organisation_document_ids" => "Worldwide organisations" })
  end
end
