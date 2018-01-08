class PublicationsController < DocumentsController
  enable_request_formats index: %i[json atom]
  before_action :expire_cache_when_next_publication_published
  before_action :redirect_statistics_filtering, only: [:index]
  before_action :redirect_statistics_documents, only: [:show]

  def index
    @filter = build_document_filter
    @filter.publications_search

    respond_to do |format|
      format.html do
        @content_item = Whitehall
          .content_store
          .content_item("/government/publications")
          .to_hash

        @filter = PublicationFilterJsonPresenter.new(
          @filter, view_context, PublicationesquePresenter
        )
      end
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
    if !request.xhr? && (params[:publication_filter_option] == 'statistics')
      redirect_to statistics_path(
        params.permit!.except(:publication_filter_option, :controller, :action, :host).to_h
      ), status: :moved_permanently
    end
  end

  def redirect_statistics_documents
    if @document.statistics?
      redirect_to public_document_path(@document), status: :moved_permanently
    end
  end
end
