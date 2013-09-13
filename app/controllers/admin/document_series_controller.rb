class Admin::DocumentSeriesController < Admin::EditionsController
  private

  def edition_class
    DocumentSeries
  end
end
