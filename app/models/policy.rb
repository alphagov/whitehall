class Policy < Document
  include Document::NationalApplicability
  include Document::Topics
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedDocuments
  include Document::SupportingDocuments
  include Document::Countries
end