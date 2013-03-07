class WorldLocationNewsArticlesController < DocumentsController
  before_filter :set_analytics_format, only:[:show]

  def show
    # so it can pretend to have orgs
    @document = WorldLocationNewsArticlePresenter.new(@document)
  end

  private

  def document_class
    WorldLocationNewsArticle
  end

  def analytics_format
    :news
  end
end
