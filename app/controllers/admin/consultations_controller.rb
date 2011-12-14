class Admin::ConsultationsController < Admin::DocumentsController

  include Admin::DocumentsController::NationalApplicability

  before_filter :build_document_attachment, only: [:new, :edit]

  def feature
    document_class.find(params[:id]).update_attribute(:featured, true)
    redirect_to :back
  end

  def unfeature
    document_class.find(params[:id]).update_attribute(:featured, false)
    redirect_to :back
  end

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