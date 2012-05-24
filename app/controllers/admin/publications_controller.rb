class Admin::PublicationsController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability

  before_filter :build_document_attachment, only: [:new, :edit]
  before_filter :build_image, only: [:new, :edit]

  private

  def document_class
    Publication
  end

  def build_document_attachment
    unless @document.edition_attachments.any?(&:new_record?)
      document_attachment = @document.edition_attachments.build
      document_attachment.build_attachment
    end
  end
end