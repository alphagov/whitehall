class Admin::ConsultationResponsesController < Admin::DocumentsController
  before_filter :build_document_attachment, only: [:new, :edit]

  private

  def document_class
    ConsultationResponse
  end

  def build_document_attachment
    unless @document.attachments.any?(&:new_record?)
      @document.attachments.build
    end
  end
end