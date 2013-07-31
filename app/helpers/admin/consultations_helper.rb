module Admin::ConsultationsHelper
  def consulation_response_help_text(response)
    if response.is_a?(ConsultationOutcome)
      "You can add attachments after saving this page."
    else
      "Optional - publish the feedback received from the public. You can add attachments after saving this page."
    end
  end
end
