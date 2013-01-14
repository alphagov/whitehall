class Admin::ConsultationsController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability
  include Admin::EditionsController::Attachments

  before_filter :build_image, only: [:new, :edit]
  before_filter :build_consultation_response_and_attachment, only: [:new, :edit]
  before_filter :cope_with_response_attachment_action_params, only: [:update]

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
    return unless params[:edition] && params[:edition][:response_attributes] && params[:edition][:response_attributes][:consultation_response_attachments_attributes]
    params[:edition][:response_attributes][:consultation_response_attachments_attributes].each do |_, consultation_response_attachments_attributes|
      Admin::AttachmentActionParamHandler.handle!(consultation_response_attachments_attributes)
    end
  end

end
