class Policy < Document
  include Document::NationalApplicability
  include Document::PolicyAreas
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedPolicies
  include Document::SupportingPages
  include Document::Countries
end