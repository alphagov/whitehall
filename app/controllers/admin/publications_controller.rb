class Admin::PublicationsController < Admin::DocumentsController
  include Admin::DocumentsController::NationalApplicability
  include Admin::DocumentsController::Featurable

  before_filter :build_document_attachment, only: [:new, :edit]

  private

  def document_class
    Publication
  end

  def build_document_attachment
    unless @document.attachments.any?(&:new_record?)
      @document.attachments.build
    end
  end
end