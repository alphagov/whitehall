class Admin::ConsultationsController < Admin::DocumentsController

  include Admin::DocumentsController::NationalApplicability

  before_filter :build_document_attachment, only: [:new, :edit]

  private

  def document_class
    Consultation
  end

  def build_document_attachment
    unless @document.attachments.any?(&:new_record?)
      @document.attachments.build
    end
  end
end