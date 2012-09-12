class Admin::ConsultationsController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability
  include Admin::EditionsController::Attachments

  before_filter :build_image, only: [:new, :edit]
  before_filter :build_consultation_response_and_attachment, only: [:new, :edit]

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
    end
  end

  def edition_class
    Consultation
  end
end
