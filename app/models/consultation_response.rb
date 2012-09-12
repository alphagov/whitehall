class ConsultationResponse < Edition
  include ::Attachable
  include Edition::AlternativeFormatProvider

  belongs_to :consultation_document, foreign_key: :consultation_document_id, class_name: 'Document'

  validates_presence_of :consultation

  def consultation
    consultation_document && (consultation_document.published_edition || consultation_document.latest_edition)
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

  def allows_attachment_references?
    true
  end

  def allows_inline_attachments?
    false
  end

  def can_have_summary?
    true
  end

  def can_have_body?
    false
  end

  private

  def body_required?
    false
  end
end
