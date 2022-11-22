module Admin::CallForEvidenceHelper
  def call_for_evidence_response_help_text(response)
    if response.is_a?(CallForEvidenceOutcome)
      "You can add attachments after saving this page."
    else
      "Optional - publish the feedback received from the public. You can add attachments after saving this page."
    end
  end

  def call_for_evidence_opening_phrase(call_for_evidence)
    return "Opening date TBC" if call_for_evidence.opening_at.nil?

    date = absolute_time(call_for_evidence.opening_at)
    ((call_for_evidence.opening_at < Time.zone.today ? "Opened at " : "Opens at ") + date).html_safe
  end

  def call_for_evidence_closing_phrase(call_for_evidence)
    return "Closing date TBC" if call_for_evidence.closing_at.nil?

    date = absolute_time(call_for_evidence.closing_at)
    ((call_for_evidence.closing_at < Time.zone.today ? "Closed at " : "Closes at ") + date).html_safe
  end
end
