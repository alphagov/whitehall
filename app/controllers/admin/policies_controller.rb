class Admin::PoliciesController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability
  before_filter :build_image, only: [:new, :edit]

  private

  def document_class
    Policy
  end
end