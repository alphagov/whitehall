class PublicationsController < DocumentsController
  enable_request_formats index: [:json, :atom]
  before_filter :expire_cache_when_next_publication_published
  before_filter :redirect_statistics_filtering, only: [:index]
  before_filter :redirect_statistics_documents, only: [:show]

  def index
    @filter = build_document_filter
    @filter.publications_search

    respond_to do |format|
      format.json do
        render json: PublicationFilterJsonPresenter.new(@filter, view_context, PublicationesquePresenter)
      end
      format.atom do
        documents = Publicationesque.published_with_eager_loading(@filter.documents.map(&:id))
        @publications = Whitehall::Decorators::CollectionDecorator.new(
          documents.sort_by(&:public_timestamp).reverse,
          PublicationesquePresenter,
          view_context,
        )
      end
    end
  end

private
  def expire_cache_when_next_publication_published
    expire_on_next_scheduled_publication(Publicationesque.scheduled.order("scheduled_publication asc"))
  end

  def redirect_statistics_filtering
    if !request.xhr? and params[:publication_filter_option] == 'statistics'
      redirect_to statistics_path(params.except(:publication_filter_option, :controller, :action)), status: :moved_permanently
    end
  end

  def redirect_statistics_documents
    if @document.statistics?
      redirect_to public_document_path(@document), status: :moved_permanently
    end
  end

  def document_class
    Publication
  end
end
