class Policy < Document
  include Document::NationalApplicability
  include Document::Topics

  has_many :supporting_documents, foreign_key: :document_id
end