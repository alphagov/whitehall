class Admin::DetailedGuidesController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability
  include Admin::EditionsController::Attachments

  before_filter :build_image, only: [:new, :edit]

  private

  def edition_class
    DetailedGuide
  end
end
