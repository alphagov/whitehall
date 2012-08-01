class SpecialistGuidesController < DocumentsController
  layout "specialist"
  before_filter :set_search_path

  def index
    load_filtered_specialist_guides(params)
  end

  def show
    @topics = @document.topics
    render action: "show"
  end

  def search
    @search_term = params[:q]
    @results = Whitehall.search_client.search(@search_term, 'specialist_guidance')
    @mainstream_results = Whitehall.mainstream_search_client.search(@search_term).take(3)
    @total_results = @results.length + @mainstream_results.length
  end

  def autocomplete
    render text: Whitehall.search_client.autocomplete(params[:q], 'specialist_guidance')
  end

private
  def document_class
    SpecialistGuide
  end

  def set_search_path
    response.headers[Slimmer::SEARCH_PATH_HEADER] = search_specialist_guides_path
  end

  def set_proposition
    set_slimmer_headers(proposition: "specialist")
  end

  def load_filtered_specialist_guides(params)
    @filter = Whitehall::DocumentFilter.new(SpecialistGuide.published.includes(:document, :organisations, :topics))
    @filter.
      by_topics(params[:topics]).
      by_organisations(params[:departments]).
      by_keywords(params[:keywords]).
      alphabetical.
      paginate(params[:page] || 1)
  end
end
