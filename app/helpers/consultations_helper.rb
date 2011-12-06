module ConsultationsHelper
  def consultation_time_remaining_phrase(consultation)
    interval = time_ago_in_words(consultation.closing_on)
    if consultation.closed?
      "Closed #{interval} ago"
    elsif consultation.open?
      "Closes in #{interval}"
    else
      "Opens in #{time_ago_in_words(consultation.opening_on)}"
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
end