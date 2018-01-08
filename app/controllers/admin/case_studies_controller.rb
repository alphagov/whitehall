class Admin::CaseStudiesController < Admin::EditionsController
private

  def edition_class
    CaseStudy
  end
end
