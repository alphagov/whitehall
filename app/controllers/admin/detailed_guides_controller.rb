class Admin::DetailedGuidesController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability

private
  def edition_class
    DetailedGuide
  end
end
