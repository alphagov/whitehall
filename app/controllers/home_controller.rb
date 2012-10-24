class HomeController < PublicFacingController
  layout 'frontend'
  before_filter :set_search_path_home, only: [:sunset]

  def show
    @recently_updated = Edition.published.by_published_at.includes(:document, :organisations).limit(10)
  end

  def sunset
    render layout: 'home'
  end

  private

  def set_search_path_home
    response.headers[Slimmer::Headers::SEARCH_PATH_HEADER] = "/search"
  end
end
