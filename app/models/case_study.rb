class CaseStudy < Edition
  include Edition::Images
  include Edition::RelatedPolicies
  include Edition::FactCheckable
  include Edition::FirstImagePulledOut
  include Edition::DocumentSeries
  include Edition::WorldLocations
  include Edition::WorldwideOrganisations
  include Edition::WorldwidePriorities

  def display_type_key
    "case_study"
  end

  def search_format_types
    super + [CaseStudy.search_format_type]
  end

  def translatable?
    !non_english_edition?
  end

  def apply_any_extra_validations_when_converting_from_imported_to_draft
    unless singleton_class.ancestors.include?(ImportToDraftValidations)
      singleton_class.send(:include, ImportToDraftValidations)
    end
  end

  module ImportToDraftValidations
    extend ActiveSupport::Concern

    included do
      validates :first_published_at, presence: true
    end
  end
end
