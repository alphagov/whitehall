module ConsultationsHelper
  def consultation_time_remaining_phrase(consultation)
    if consultation.open?
      closing_interval = time_ago_in_words(consultation.closing_on + 1.day)
      "Closes in #{closing_interval}"
    elsif consultation.not_yet_open?
      opening_interval = time_ago_in_words(consultation.opening_on)
      "Opens in #{opening_interval}"
    else
      ""
    end
  end

  def consultation_opening_phrase(consultation)
    date = render_datetime_microformat(consultation, :opening_on) { consultation.opening_on.to_s(:long_ordinal) }
    (((consultation.opening_on < Date.today) ? "Opened on " : "Opens on ") + date).html_safe
  end

  def consultation_closing_phrase(consultation)
    date = render_datetime_microformat(consultation, :closing_on) { consultation.closing_on.to_s(:long_ordinal) }
    (((consultation.closing_on < Date.today) ? "Closed on " : "Closes on ") + date).html_safe
  end

  def consultation_css_class(consultation)
    'consultation' + if consultation.response_published?
      ' consultation-responded'
    elsif consultation.closed?
      ' consultation-closed'
    elsif consultation.open?
      ' consultation-open'
    end
  end

  def consultation_header_title(consultation)
    if consultation.response_published?
      "Consultation outcome"
    elsif consultation.closed?
      "Closed consultation"
    elsif consultation.open?
      "Open consultation"
    else
      "Consultation"
    end
  end
end
