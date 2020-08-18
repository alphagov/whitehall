class PublicationsController < DocumentsController
  enable_request_formats index: %i[json atom]
  before_action :expire_cache_when_next_publication_published
  before_action :redirect_statistics_filtering, only: [:index]
  before_action :redirect_statistics_documents, only: [:show]
  include PublicationsRoutes

  def show
    super
  end

  def index
    return redirect_formats_to_finder_frontend if Locale.current.english?

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

  def redirect_formats_to_finder_frontend
    respond_to do |format|
      format.html do
        redirect_to_finder_frontend_finder
      end
      format.json do
        redirect_to_finder_frontend_finder(".json")
      end
      format.atom do
        redirect_to_finder_frontend_finder(".atom")
      end
    end
  end

  def redirect_to_finder_frontend_finder(format = "")
    base_path = "#{Plek.new.website_root}/#{publications_base_path}#{format}"
    if publications_query_string == ""
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
    allowed_params = cleaned_document_filter_params
    level_one_taxon = allowed_params["taxons"].try(:first) || allowed_params["topics"].try(:first)
    level_two_taxon = allowed_params["subtaxons"].try(:first)
    level_one_taxon = nil if level_one_taxon == "all"
    level_two_taxon = nil if level_two_taxon == "all"
    {
      keywords: params["keywords"],
      level_one_taxon: level_one_taxon,
      level_two_taxon: level_two_taxon,
      organisations: filter_query_array(allowed_params["departments"] || allowed_params["organisations"]),
      people: filter_query_array(allowed_params["people"]),
      world_locations: filter_query_array(allowed_params["world_locations"]),
      topical_events: filter_query_array(allowed_params["topical_events"]),
      public_timestamp: { from: allowed_params["from_date"], to: allowed_params["to_date"] }.compact.presence,
    }.compact.merge(special_params).to_query
  end

  def publication_finder_type
    params[:official_document_status] || params[:publication_filter_option] || params[:publication_type]
  end

  def expire_cache_when_next_publication_published
    expire_on_next_scheduled_publication(Publicationesque.scheduled.order("scheduled_publication asc"))
  end

  def redirect_statistics_filtering
    if !request.xhr? && (params[:publication_filter_option] == "statistics")
      redirect_to statistics_path(
        Whitehall::DocumentFilter::CleanedParams.new(
          params.except(:publication_filter_option, :controller, :action, :host),
        ),
        status: :moved_permanently,
      )
    end
  end

  def redirect_statistics_documents
    if @document.statistics?
      redirect_to public_document_path(@document), status: :moved_permanently
    end
  end
end
