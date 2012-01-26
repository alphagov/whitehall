class Admin::ConsultationsController < Admin::DocumentsController
  include Admin::DocumentsController::NationalApplicability

  before_filter :build_document_attachment, only: [:new, :edit]

  private

  def document_class
    Consultation
  end

  def build_document_attachment
    unless @document.document_attachments.any?(&:new_record?)
      document_attachment = @document.document_attachments.build
      document_attachment.build_attachment
    end
  end
end