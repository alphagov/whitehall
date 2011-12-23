class NewsArticlesController < DocumentsController
  def index
    @news_articles = NewsArticle.published.by_published_at
  end

  def show
    @related_policies = @document.published_related_policies
  end

  private

  def document_class
    NewsArticle
  end
end