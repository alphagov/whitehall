class Admin::ConsultationsController < Admin::EditionsController
  before_action :cope_with_consultation_response_form_data_action_params, only: [:update]

private

  def edition_class
    Consultation
  end

  def cope_with_consultation_response_form_data_action_params
    return if edition_params.empty?
    # NOTE: this is slightly different to what happens above in that
    # replace here will not create a new object and set up a replaced_by
    # but just does a simple attribute value overwrite (e.g. a normal
    # update). This is because consultation_participation objects are not
    # (yet) versioned with their editions like attachments are.
    return unless edition_params.dig(:consultation_participation_attributes, :consultation_response_form_attributes)

    response_form_params = edition_params[:consultation_participation_attributes][:consultation_response_form_attributes]

    if response_form_params[:id]
      case response_form_params.delete(:attachment_action).to_s.downcase
      when "keep"
        response_form_params.delete(:_destroy)
        response_form_params.delete(:consultation_response_form_data_attributes)
      when "remove"
        response_form_params["_destroy"] = "1"
        response_form_params.delete(:consultation_response_form_data_attributes)
      when "replace"
        response_form_params.delete(:_destroy)
      else
        response_form_params.delete(:_destroy)
        response_form_params.delete(:consultation_response_form_data_attributes)
      end
    end
  end

  def document_can_be_previously_published
    false
  end

  def build_edition_dependencies
    super
    participation = @edition.consultation_participation || @edition.build_consultation_participation
    response_form = participation.consultation_response_form || participation.build_consultation_response_form
    response_form.consultation_response_form_data || response_form.build_consultation_response_form_data
  end
end
