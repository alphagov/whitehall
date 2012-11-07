class CaseStudy < Edition
  include Edition::Images
  include Edition::RelatedPolicies
  include Edition::FactCheckable
  include Edition::FirstImagePulledOut

  def can_have_summary?
    true
  end
end
