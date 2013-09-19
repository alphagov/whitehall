class DocumentSeriesController < DocumentsController
  def show
    expire_on_next_scheduled_publication(@document.editions)
    @document_series = DocumentSeriesPresenter.new(@document, view_context)
    @meta_description = @document_series.summary
  end

private
  def document_class
    DocumentSeries
  end
end
