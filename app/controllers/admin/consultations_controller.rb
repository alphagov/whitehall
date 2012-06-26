class Admin::ConsultationsController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability
  include Admin::EditionsController::Attachments

  before_filter :build_image, only: [:new, :edit]

  private

  def edition_class
    Consultation
  end
end
