class DetailedGuidesController < DocumentsController
  layout "detailed-guidance"
  skip_before_filter :set_search_path
  before_filter :set_search_index
  before_filter :set_artefact, only: [:show]
  before_filter :set_expiry, only: [:show]
  before_filter :set_analytics_format, only: [:show]

  def show
    @categories = non_sector_mainstream_categories
    @topics = @document.topics
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

  def set_slimmer_proposition
    set_slimmer_headers(proposition: "specialist")
  end

  def set_artefact
    breadcrumb_trail = BreadcrumbTrail.for(@document)
    set_slimmer_artefact breadcrumb_trail if breadcrumb_trail.valid?
  end

  def canonical_redirect_path(redir_params)
    # There's no index for detailed guides, so we don't need to worry
    # about this complaing about a lack of id
    detailed_guide_url(redir_params.except(:controller, :action))
  end

  def non_sector_mainstream_categories
    @document.mainstream_categories.reject {|category|
      category.slug =~ /\Aindustry-sector/
    }
  end
end
