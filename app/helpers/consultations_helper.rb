module ConsultationsHelper
  def consultation_opening_phrase(consultation)
    return 'Opening date TBC' if consultation.opening_on.nil?
    date = render_datetime_microformat(consultation, :opening_on) { consultation.opening_on.to_s(:long_ordinal) }
    (((consultation.opening_on < Date.today) ? "Opened on " : "Opens on ") + date).html_safe
  end

  def consultation_closing_phrase(consultation)
    return 'Closing date TBC' if consultation.closing_on.nil?
    date = render_datetime_microformat(consultation, :closing_on) { consultation.closing_on.to_s(:long_ordinal) }
    (((consultation.closing_on < Date.today) ? "Closed on " : "Closes on ") + date).html_safe
  end

  def consultation_response_published_phrase(response)
    if response.published_on
      date = render_datetime_microformat(response, :published_on) { response.published_on.to_s(:long_ordinal) }
      "Published response on #{date}".html_safe
    else
      'Not yet published'
    end
  end

  def consultation_css_class(consultation)
    consultation_class = ''
    if consultation.response_published?
      consultation_class = 'consultation-responded'
    elsif consultation.closed?
      consultation_class = 'consultation-closed'
    elsif consultation.open?
      consultation_class = 'consultation-open'
    end
    "consultation #{consultation_class}"
  end
end
