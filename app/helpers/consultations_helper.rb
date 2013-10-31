module ConsultationsHelper
  def consultation_opening_phrase(consultation)
    return 'Opening date TBC' if consultation.opening_at.nil?
    date = absolute_time(consultation.opening_at)
    (((consultation.opening_at < Date.today) ? "Opened on " : "Opens on ") + date).html_safe
  end

  def consultation_closing_phrase(consultation)
    return 'Closing date TBC' if consultation.closing_at.nil?
    date = absolute_time(consultation.closing_at)
    (((consultation.closing_at < Date.today) ? "Closed on " : "Closes on ") + date).html_safe
  end

  def consultation_css_class(consultation)
    consultation_class = ''
    if consultation.outcome_published?
      consultation_class = 'consultation-responded'
    elsif consultation.closed?
      consultation_class = 'consultation-closed'
    elsif consultation.open?
      consultation_class = 'consultation-open'
    end
    "consultation #{consultation_class}"
  end
end
