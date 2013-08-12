class Admin::DocumentSeriesMembershipsController  < Admin::BaseController
  before_filter :load_document_series
  before_filter :load_document, only: [:create, :destroy]

  def index
  end

  def create
    @document_series.documents << @document
    flash.now[:notice] = %Q("#{@document.latest_edition.title}" added to series)
  end

  def destroy
    @document_series.documents.delete(@document)
    flash.now[:notice] = %Q("#{@document.latest_edition.title}" removed from series)
  end

  private

  def load_document_series
    @document_series = DocumentSeries.find(params[:document_series_id])
  end

  def load_document
    @document = Document.find(params[:id])
  end
end
