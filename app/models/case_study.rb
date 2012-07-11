class CaseStudy < Edition
  include Edition::RelatedPolicies
  include Edition::FactCheckable
end
