module ConsultationsHelper
  def consultation_time_remaining_phrase(consultation)
    closing_interval = time_ago_in_words(consultation.closing_on + 1.day)
    if consultation.response_published?
      response_interval = time_ago_in_words(consultation.response_published_on)
      "Response published #{response_interval} ago"
    elsif consultation.closed?
      "Closed #{closing_interval} ago"
    elsif consultation.open?
      "Closes in #{closing_interval}"
    else
      opening_interval = time_ago_in_words(consultation.opening_on)
      "Opens in #{opening_interval}"
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