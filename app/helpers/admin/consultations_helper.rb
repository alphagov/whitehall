module Admin::ConsultationsHelper
  def consulation_response_help_text(response)
    if response.is_a?(ConsultationOutcome)
      "Here you can publish the final outcome of the consultation. 
       Either provide the full details of the outcome below, or provide
       a summary here and upload the full outcome as an attachment once you have saved a summary."
    else
      "Here you can publish the feedback received from the public on this consultation.
       Once you have saved a summary, you will be able to upload attachments containing their feedback.
       Note that publishing public feedback is optional"
    end
  end
end