class Admin::PoliciesController < Admin::DocumentsController

  include Admin::DocumentsController::NationalApplicability

  private

  def document_class
    Policy
  end
end