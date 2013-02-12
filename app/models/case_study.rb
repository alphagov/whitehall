class CaseStudy < Edition
  include Edition::Images
  include Edition::RelatedPolicies
  include Edition::FactCheckable
  include Edition::FirstImagePulledOut

  def display_type_key
    "case_study"
  end

  def search_format_types
    super + ['case-study']
  end
end
