class Admin::StatisticalDataSetsController < Admin::EditionsController
  include Admin::EditionsController::Attachments

  private

  def edition_class
    StatisticalDataSet
  end
end
