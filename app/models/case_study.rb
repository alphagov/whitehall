class CaseStudy < Edition
  include Edition::Images
  include Edition::RelatedPolicies
  include Edition::FactCheckable
  include Edition::FirstImagePulledOut
end
