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
      "Closed Consultation"
    elsif consultation.open?
      "Open Consultation"
    else
      "Consultation"
    end
  end

  def link_to_consultation_participation(consultation, *args)
    link_to consultation.consultation_participation.link_text, consultation.consultation_participation.link_url, *args
  end

  def mail_to_consultation_participation(consultation, *args)
    mail_to consultation.consultation_participation.email, *args
  end

  def consultation_participation_options(consultation_participation)
    options = []
    if consultation_participation.has_link?
      options << content_tag(:p, link_to(consultation_participation.link_text, consultation_participation.link_url), class: "online")
    end
    if consultation_participation.has_email? || consultation_participation.has_postal_address?
      respond_by = ""
      if consultation_participation.has_email?
        respond_by << content_tag(:dl, "email")
        respond_by << content_tag(:dd, mail_to(consultation_participation.email), class: "email")
      end
      if consultation_participation.has_postal_address?
        respond_by << content_tag(:dl, "post")
        respond_by << content_tag(:dd, format_with_html_line_breaks(consultation_participation.postal_address), class: "postal-address")
      end
      if consultation_participation.has_response_form?
        header = "Return the form to us by#{consultation_participation.has_postal_address? && consultation_participation.has_email? ? ' either': ''}:"
      else
        header = "Contact us by#{consultation_participation.has_postal_address? && consultation_participation.has_email? ? ' either': ''}:"
      end
      respond_by = content_tag(:dl,
        respond_by.html_safe
      )
      if consultation_participation.has_response_form?
        options << content_tag(:ol,
          content_tag(:li, content_tag(:p,
            "Download and complete the response form:") +
            link_to(consultation_participation.consultation_response_form.title,
                    consultation_participation.consultation_response_form.file.url)
          ) +
          content_tag(:li,
                      content_tag(:p, header) +
            respond_by
          )
        )
      else
        options << content_tag(:div,
                               content_tag(:p, header) + respond_by)
      end
    end
    options.join(content_tag(:p, "or", class: "or")).html_safe
  end
end
