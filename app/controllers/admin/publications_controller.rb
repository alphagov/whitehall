class Admin::PublicationsController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability

  before_filter :build_image, only: [:new, :edit]

  private

  def edition_class
    Publication
  end
end
