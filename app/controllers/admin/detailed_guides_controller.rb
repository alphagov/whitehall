class Admin::DetailedGuidesController < Admin::EditionsController
private

  def edition_class
    DetailedGuide
  end
end
