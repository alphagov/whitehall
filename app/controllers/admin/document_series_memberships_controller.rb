class Admin::DocumentSeriesMembershipsController  < Admin::BaseController
  before_filter :load_document_series
  before_filter :load_document, only: [:create, :destroy]

  def create
    @document_series.documents << @document
    flash.now[:notice] = %Q("#{document_title}" added to series)
  end

  def destroy
    @document_series.documents.delete(@document)
    flash.now[:notice] = %Q("#{document_title}" removed from series)
  end

  def search
    filter_options = params.slice(:title).merge(state: 'active', per_page: 10)
    @filter = Admin::EditionFilter.new(Edition, current_user, filter_options)
  end

  private
  def load_document_series
    @document_series = DocumentSeries.find(params[:document_series_id])
  end

  def load_document
    @document = Document.find(params[:id])
  end

  def document_title
    @document.latest_edition.title
  end
end
