class ConsultationResponse < Document
  belongs_to :consultation_document_identity, class_name: 'DocumentIdentity'

  validates_presence_of :consultation

  def consultation
    consultation_document_identity && consultation_document_identity.published_document
  end

  def consultation=(c)
    self.consultation_document_identity = c && c.document_identity
  end
end