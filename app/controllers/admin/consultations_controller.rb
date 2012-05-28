class Admin::ConsultationsController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability

  before_filter :build_edition_attachment, only: [:new, :edit]
  before_filter :build_image, only: [:new, :edit]

  private

  def document_class
    Consultation
  end

  def build_edition_attachment
    unless @document.edition_attachments.any?(&:new_record?)
      edition_attachment = @document.edition_attachments.build
      edition_attachment.build_attachment
    end
  end
end