class Admin::ConsultationsController < Admin::DocumentsController
  private

  def document_class
    Consultation
  end
end