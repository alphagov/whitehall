class Admin::SpecialistGuidesController < Admin::EditionsController
  include Admin::EditionsController::Attachments

  before_filter :build_image, only: [:new, :edit]

  private

  def edition_class
    SpecialistGuide
  end
end
