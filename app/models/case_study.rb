class CaseStudy < Edition
  include Edition::Images
  include Edition::RelatedPolicies
  include Edition::FactCheckable

  def can_have_summary?
    true
  end
end
