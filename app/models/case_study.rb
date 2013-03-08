class CaseStudy < Edition
  include Edition::Images
  include Edition::RelatedPolicies
  include Edition::FactCheckable
  include Edition::FirstImagePulledOut
  include Edition::DocumentSeries

  def display_type_key
    "case_study"
  end

  def search_format_types
    super + [CaseStudy.search_format_type]
  end

  def translatable?
    true
  end

  def apply_any_extra_validations_when_converting_from_imported_to_draft
    class << self
      validates :first_published_at, presence: true
    end
  end
end
