class StatisticalDataSetsController < DocumentsController
  def show
    set_meta_description(@document.summary)
  end

  private

  def document_class
    StatisticalDataSet
  end
end
