class DetailedGuidesController < DocumentsController
  layout "detailed-guidance"
  skip_before_filter :set_search_path
  before_filter :set_search_index
  before_filter :set_artefact, only: [:show]

  respond_to :html, :json

  def index
    params[:page] ||= 1
    params[:direction] = "alphabetical"
    @filter = Whitehall::DocumentFilter.new(all_detailed_guides, params)
    respond_with DetailedGuideFilterJsonPresenter.new(@filter)
  end

  def show
    @categories = @document.mainstream_categories
    @topics = @document.topics
    render action: "show"
  end

private
  def document_class
    DetailedGuide
  end

  def all_detailed_guides
    DetailedGuide.published.includes(:document, :organisations, :topics)
  end

  def set_search_index
    response.headers[Slimmer::Headers::SEARCH_INDEX_HEADER] = 'detailed'
  end

  def set_proposition
    set_slimmer_headers(proposition: "specialist")
  end

  def set_artefact
    breadcrumb_trail = BreadcrumbTrail.for(@document)
    set_slimmer_artefact breadcrumb_trail if breadcrumb_trail.valid?
  end

end
