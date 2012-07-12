class CaseStudy < Edition
  include Edition::RelatedPolicies
  include Edition::FactCheckable

  def has_summary?
    true
  end
end
