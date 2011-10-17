class Admin::PoliciesController < Admin::DocumentsController
  private

  def document_class
    Policy
  end
end