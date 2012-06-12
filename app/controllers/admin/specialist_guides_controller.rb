class Admin::SpecialistGuidesController < Admin::EditionsController
  before_filter :build_image, only: [:new, :edit]

  private

  def edition_class
    SpecialistGuide
  end
end
