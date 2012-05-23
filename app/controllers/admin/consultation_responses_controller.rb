class Admin::ConsultationResponsesController < Admin::DocumentsController
  before_filter :build_document_attachment, only: [:new, :edit]

  private

  def document_class
    ConsultationResponse
  end

  def build_document_attachment
    unless @document.edition_attachments.any?(&:new_record?)
      document_attachment = @document.edition_attachments.build
      document_attachment.build_attachment
    end
  end
end