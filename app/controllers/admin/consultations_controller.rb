class Admin::ConsultationsController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability
  include Admin::EditionsController::HtmlVersion

  before_filter :build_image, only: [:new, :edit]
  before_filter :build_consultation_response_and_attachment, only: [:new, :edit]
  before_filter :cope_with_response_attachment_action_params, only: [:update]
  before_filter :cope_with_consultation_response_form_data_action_params, only: [:update]

  private

  def build_edition_dependencies
    super
    build_consultation_response_and_attachment
  end

  def build_consultation_response_and_attachment
    @edition.build_response unless @edition.response.present?

    unless @edition.response.consultation_response_attachments.any?(&:new_record?)
      response_attachment = @edition.response.consultation_response_attachments.build
    end

    @edition.response.consultation_response_attachments.each do |response_attachment|
      response_attachment.build_attachment unless response_attachment.attachment.present?
      response_attachment.attachment.build_attachment_data unless response_attachment.attachment.attachment_data.present?
    end
  end

  def edition_class
    Consultation
  end

  def cope_with_response_attachment_action_params
    return unless params[:edition] &&
                  params[:edition][:response_attributes] &&
                  params[:edition][:response_attributes][:consultation_response_attachments_attributes]
    params[:edition][:response_attributes][:consultation_response_attachments_attributes].each do |_, consultation_response_attachments_attributes|
      Admin::AttachmentActionParamHandler.manipulate_params!(consultation_response_attachments_attributes)
    end
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
