class Admin::PoliciesController < Admin::DocumentsController
  include Admin::DocumentsController::NationalApplicability
  before_filter :build_image, only: [:new, :edit]

  private

  def document_class
    Policy
  end
end