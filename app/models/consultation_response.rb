class ConsultationResponse < Document
  include Document::Attachable

  belongs_to :consultation_document_identity, class_name: 'DocumentIdentity'

  validates_presence_of :consultation

  def consultation
    consultation_document_identity && consultation_document_identity.published_document
  end

  def consultation=(c)
    self.consultation_document_identity = c && c.document_identity
  end

  def consultation_id
    self.consultation && self.consultation.id
  end

  def consultation_id=(id)
    self.consultation = Consultation.find(id)
  end
end