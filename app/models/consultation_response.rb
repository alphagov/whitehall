class ConsultationResponse < Edition
  include Edition::Attachable

  belongs_to :consultation_doc_identity, foreign_key: :consultation_document_id, class_name: 'DocIdentity'

  validates_presence_of :consultation

  def consultation
    consultation_doc_identity && consultation_doc_identity.published_edition
  end

  def consultation=(c)
    self.consultation_doc_identity = c && c.doc_identity
  end

  def consultation_id
    self.consultation && self.consultation.id
  end

  def consultation_id=(id)
    self.consultation = Consultation.find(id)
  end
end
