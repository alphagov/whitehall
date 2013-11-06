module Admin::ConsultationsHelper
  def consulation_response_help_text(response)
    if response.is_a?(ConsultationOutcome)
      "You can add attachments after saving this page."
    else
      "Optional - publish the feedback received from the public. You can add attachments after saving this page."
    end
  end

  def consultation_opening_phrase(consultation)
    return 'Opening date TBC' if consultation.opening_at.nil?
    date = absolute_time(consultation.opening_at)
    (((consultation.opening_at < Date.today) ? "Opened at " : "Opens at ") + date).html_safe
  end

  def consultation_closing_phrase(consultation)
    return 'Closing date TBC' if consultation.closing_at.nil?
    date = absolute_time(consultation.closing_at)
    (((consultation.closing_at < Date.today) ? "Closed at " : "Closes at ") + date).html_safe
  end
end
