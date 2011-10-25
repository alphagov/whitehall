class Policy < Document
  include Document::NationalApplicability

  has_many :supporting_documents, foreign_key: :document_id
end