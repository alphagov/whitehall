class AttachmentValidator < ActiveModel::Validator

  def validate(attachment)
    check_unnumbered_command_papers_dont_have_numbers(attachment)
    check_unnumbered_hoc_papers_dont_have_numbers(attachment)
    check_unnumbered_command_paper_has_no_hoc_paper_metadata(attachment)
    check_unnumbered_hoc_paper_has_no_command_paper_metadata(attachment)
    check_if_hoc_paper_number_required(attachment)
    check_if_parliamentary_session_required(attachment)
    check_format_of_hoc_paper_number(attachment)
  end

  private
  def check_unnumbered_command_papers_dont_have_numbers(attachment)
    if attachment.unnumbered_command_paper? && attachment.command_paper_number.present?
      attachment.errors[:command_paper_number] << 'cannot be set on an unnumbered paper'
    end
  end

  def check_unnumbered_hoc_papers_dont_have_numbers(attachment)
    if attachment.unnumbered_hoc_paper?
      if attachment.hoc_paper_number.present?
        attachment.errors[:hoc_paper_number] << 'cannot be set on an unnumbered paper'
      elsif attachment.parliamentary_session.present?
        attachment.errors[:parliamentary_session] << 'cannot be set on an unnumbered paper'
      end
    end
  end

  def check_unnumbered_command_paper_has_no_hoc_paper_metadata(attachment)
    if attachment.unnumbered_command_paper?
      if attachment.unnumbered_hoc_paper?
        attachment.errors[:unnumbered_hoc_paper] << 'cannot be set on an unnumbered Command Paper'
      end
      if attachment.hoc_paper_number.present?
        attachment.errors[:hoc_paper_number] << 'cannot be set on a Command Paper'
      end
      if attachment.hoc_paper_number.present?
        attachment.errors[:parliamentary_session] << 'cannot be set on a Command Paper'
      end
    end
  end

  def check_unnumbered_hoc_paper_has_no_command_paper_metadata(attachment)
    if attachment.unnumbered_hoc_paper? && attachment.command_paper_number.present?
      attachment.errors[:command_paper_number] << 'cannot be set on a House of Commons paper'
    end
  end

  def check_if_hoc_paper_number_required(attachment)
    if attachment.parliamentary_session.present? && attachment.hoc_paper_number.blank?
      attachment.errors[:hoc_paper_number] << 'is required when parliamentary session is set'
    end
  end

  def check_if_parliamentary_session_required(attachment)
    if attachment.hoc_paper_number.present? && attachment.parliamentary_session.blank?
      attachment.errors[:parliamentary_session] << 'is required when House of Commons number is set'
    end
  end

  def check_format_of_hoc_paper_number(attachment)
    number = attachment.hoc_paper_number
    if number.present? && (number !~ /^\d{4}/)
      attachment.errors[:hoc_paper_number] << 'must start with a number'
    end
  end
end
