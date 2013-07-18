class AttachmentValidator < ActiveModel::Validator

  def validate(attachment)
    check_hoc_paper_number(attachment)
    check_parliamentary_session(attachment)
  end

  private
  def check_hoc_paper_number(attachment)
    if attachment.parliamentary_session.present? && attachment.hoc_paper_number.blank?
      attachment.errors[:hoc_paper_number] = 'is required when parliamentary session is set'
    end
  end

  def check_parliamentary_session(attachment)
    if attachment.hoc_paper_number.present? && attachment.parliamentary_session.blank?
      attachment.errors[:parliamentary_session] = 'is required when House of Commons number is set'
    end
  end
end
