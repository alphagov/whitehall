class DetailedGuidesController < DocumentsController

  layout "detailed-guidance"
  skip_before_filter :set_search_path
  before_filter :set_search_index
  before_filter :set_artefact, only: [:show]
  before_filter :set_expiry, only: [:show]
  before_filter :set_analytics_format, only: [:show]

  respond_to :html, :json

  def show
    @categories = @document.mainstream_categories
    @topics = @document.topics
    render action: "show"
  end

private
  def document_class
    DetailedGuide
  end

  def analytics_format
    :detailed_guidance
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
