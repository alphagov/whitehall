class ConsultationResponse < Edition
  include Edition::Attachable

  belongs_to :consultation_document, foreign_key: :consultation_document_id, class_name: 'Document'

  validates_presence_of :consultation

  def consultation
    consultation_document && consultation_document.published_edition
  end

  def consultation=(c)
    self.consultation_document = c && c.document
  end

  def consultation_id
    self.consultation && self.consultation.id
  end

  def consultation_id=(id)
    self.consultation = Consultation.find(id)
  end

  def alternative_format_contact_email
    consultation && consultation.alternative_format_contact_email
  end
end
