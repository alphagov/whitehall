class AttachmentValidator < ActiveModel::Validator

  def validate(attachment)
    check_if_hoc_paper_number_required(attachment)
    check_if_parliamentary_session_required(attachment)
    check_format_of_hoc_paper_number(attachment)
  end

  private
  def check_if_hoc_paper_number_required(attachment)
    if attachment.parliamentary_session.present? && attachment.hoc_paper_number.blank?
      attachment.errors[:hoc_paper_number] = 'is required when parliamentary session is set'
    end
  end

  def check_if_parliamentary_session_required(attachment)
    if attachment.hoc_paper_number.present? && attachment.parliamentary_session.blank?
      attachment.errors[:parliamentary_session] = 'is required when House of Commons number is set'
    end
  end

  def check_format_of_hoc_paper_number(attachment)
    number = attachment.hoc_paper_number
    if number.present? && (number !~ /^\d{4}/)
      attachment.errors[:hoc_paper_number] = 'must start with a number'
    end
  end
end
