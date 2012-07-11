class Admin::CaseStudiesController < Admin::EditionsController
  before_filter :build_image, only: [:new, :edit]

  private

  def edition_class
    CaseStudy
  end
end
