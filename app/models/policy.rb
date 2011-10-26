class Policy < Document
  include Document::NationalApplicability
  include Document::Topics
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedDocuments

  has_many :supporting_documents, foreign_key: :document_id
end