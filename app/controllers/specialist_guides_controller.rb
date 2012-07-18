class SpecialistGuidesController < DocumentsController
  layout "specialist"
  before_filter :set_search_path

  def index
    if params[:group_by] == 'organisations'
      @grouped_published_specialist_guides = Organisation.joins(:published_specialist_guides).includes(:published_specialist_guides)
    else
      @grouped_published_specialist_guides = Topic.joins(:published_specialist_guides).includes(:published_specialist_guides)
    end
  end

  def show
    @topics = @document.topics
  end

  def search
    @search_term = params[:q]
    if @search_term.present?
      @results = search_client.search(@search_term, 'specialist_guide')
    else
      @results = []
    end
  end

  def autocomplete
    render text: search_client.autocomplete(params[:q], 'specialist_guide')
  end

private
  def search_client
    Whitehall::SearchClient.new
  end

  def document_class
    SpecialistGuide
  end

  def set_search_path
    response.headers[Slimmer::SEARCH_PATH_HEADER] = search_specialist_guides_path
  end

  def set_proposition
    set_slimmer_headers(proposition: "specialist")
  end
end
