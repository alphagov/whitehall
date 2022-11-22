class Admin::CallForEvidenceController < Admin::EditionsController
  before_action :cope_with_call_for_evidence_response_form_data_action_params, only: [:update]

private

  def edition_class
    CallForEvidence
  end

  def cope_with_call_for_evidence_response_form_data_action_params
    return if edition_params.empty?
    # NOTE: this is slightly different to what happens above in that
    # replace here will not create a new object and set up a replaced_by
    # but just does a simple attribute value overwrite (e.g. a normal
    # update). This is because call_for_evidence_participation objects are not
    # (yet) versioned with their editions like attachments are.
    return unless edition_params[:call_for_evidence_participation_attributes] &&
      edition_params[:call_for_evidence_participation_attributes][:call_for_evidence_response_form_attributes]

    response_form_params = edition_params[:call_for_evidence_participation_attributes][:call_for_evidence_response_form_attributes]

    if response_form_params[:id]
      case response_form_params.delete(:attachment_action).to_s.downcase
      when "keep"
        response_form_params.delete(:_destroy)
        response_form_params.delete(:call_for_evidence_response_form_data_attributes)
      when "remove"
        response_form_params["_destroy"] = "1"
        response_form_params.delete(:call_for_evidence_response_form_data_attributes)
      when "replace"
        response_form_params.delete(:_destroy)
      else
        response_form_params.delete(:_destroy)
        response_form_params.delete(:call_for_evidence_response_form_data_attributes)
      end
    end
  end

  def document_can_be_previously_published
    false
  end
end
