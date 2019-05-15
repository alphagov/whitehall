class PublicationsController < DocumentsController
  enable_request_formats index: %i[json atom]
  before_action :expire_cache_when_next_publication_published
  before_action :redirect_statistics_filtering, only: [:index]
  before_action :redirect_statistics_documents, only: [:show]
  include PublicationsRoutes

  def index
    @filter = build_document_filter
    @filter.publications_search

    respond_to do |format|
      format.html do
        return redirect_to_finder_frontend_finder if Locale.current.english?

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

  def redirect_to_finder_frontend_finder
    base_path = "#{Plek.new.website_root}/#{publications_base_path}"
    if publications_query_string == ''
      redirect_to(base_path)
    else
      redirect_to("#{base_path}?#{publications_query_string}")
    end
  end

  def publications_base_path
    base_path = PUBLICATIONS_ROUTES.dig(publication_finder_type, :base_path)
    base_path || DEFAULT_PUBLICATIONS_PATH
  end

  def special_params
    PUBLICATIONS_ROUTES.dig(publication_finder_type, :special_params) || {}
  end

  def publications_query_string
    {
      keywords: params['keywords'],
      level_one_taxon: params['taxons'].try(:first) || params['topics'].try(:first),
      level_two_taxon: params['subtaxons'].try(:first),
      organisations: params['departments'] || params['organisations'],
      people: params['people'],
      world_locations: params['world_locations'],
      public_timestamp: { from: params['from_date'], to: params['to_date'] }.compact.presence
    }.compact.merge(special_params).to_query
  end

  def publication_finder_type
    params[:publication_filter_option] || params[:publication_type]
  end

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
