class Policy < Document
  include Document::NationalApplicability
  include Document::Topics
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedDocuments
  include Document::SupportingPages
  include Document::Countries
end