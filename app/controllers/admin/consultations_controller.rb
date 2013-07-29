class Admin::ConsultationsController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability

  before_filter :build_html_version, only: [:new, :edit]
  before_filter :build_image, only: [:new, :edit]
  before_filter :cope_with_consultation_response_form_data_action_params, only: [:update]

  private

  def edition_class
    Consultation
  end

  def cope_with_consultation_response_form_data_action_params
    # NOTE: this is slightly different to what happens above in that
    # replace here will not create a new onbject and set up a replaced_by
    # but just does a simple attribute value overwrite (e.g. a normal
    # update). This is because consultation_participation objects are not
    # (yet) versioned with their editions like attachments are.
    return unless params[:edition] &&
        params[:edition][:consultation_participation_attributes] &&
        params[:edition][:consultation_participation_attributes][:consultation_response_form_attributes]
    response_form_params = params[:edition][:consultation_participation_attributes][:consultation_response_form_attributes]

    if response_form_params[:id]
      case response_form_params.delete(:attachment_action).to_s.downcase
      when 'keep'
        response_form_params.delete(:_destroy)
        response_form_params.delete(:consultation_response_form_data_attributes)
      when 'remove'
        response_form_params['_destroy'] = '1'
        response_form_params.delete(:consultation_response_form_data_attributes)
      when 'replace'
        response_form_params.delete(:_destroy)
      else
        response_form_params.delete(:_destroy)
        response_form_params.delete(:consultation_response_form_data_attributes)
      end
    end
  end

end
