class WorldLocationNewsArticlesController < DocumentsController
  before_filter :set_analytics_format, only: :show

  def show
    # so it can pretend to have orgs
    @document = WorldLocationNewsArticlePresenter.new(@document)
  end

  def index
    redirect_to announcements_path(include_world_location_news: "1")
  end

  private

  def document_class
    WorldLocationNewsArticle
  end

  def analytics_format
    :news
  end
end
