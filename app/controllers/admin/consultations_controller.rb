class Admin::ConsultationsController < Admin::DocumentsController

  include Admin::DocumentsController::NationalApplicability

  private

  def document_class
    Consultation
  end
end