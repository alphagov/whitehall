class Admin::PoliciesController < Admin::DocumentsController

  include Admin::Documents::NationalApplicability

  private

  def document_class
    Policy
  end
end