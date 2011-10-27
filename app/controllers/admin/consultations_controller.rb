class Admin::ConsultationsController < Admin::DocumentsController

  include Admin::Documents::NationalApplicability

  private

  def document_class
    Consultation
  end
end