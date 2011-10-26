module Document::SupportingDocuments
  extend ActiveSupport::Concern

  included do
    has_many :supporting_documents, foreign_key: :document_id
  end

  def allows_supporting_documents?
    true
  end

  def has_supporting_documents?
    supporting_documents.any?
  end
end