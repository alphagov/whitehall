class PublicationsController < DocumentsController
  class PublicationesqueDecorator < SimpleDelegator
    def documents
      PublicationesquePresenter.decorate(__getobj__.documents)
    end
  end

  def index
    params[:page] ||= 1
    params[:direction] ||= "before"
    document_filter = Whitehall::DocumentFilter.new(all_publications, params)
    @filter = PublicationesqueDecorator.new(document_filter)

    respond_to do |format|
      format.html
      format.json do
        render json: PublicationFilterJsonPresenter.new(@filter)
      end
      format.atom do
        @publications = @filter.documents
      end
    end
  end

  def show
    @related_policies = @document.statistics? ? [] : @document.published_related_policies
    @related_statistical_data_sets = StatisticalDataSetPresenter.decorate(@document.published_statistical_data_sets)
  end

private

  def all_publications
    Publicationesque.published.includes(:document, :organisations, :attachments, response: :attachments)
  end

  def document_class
    Publication
  end
end
