class NewsArticlesController < DocumentsController
  def index
    @news_articles = NewsArticle.published.by_first_published_at
  end

  def show
    @related_policies = @document.published_related_policies
    @document = NewsArticlePresenter.decorate(@document)
  end

  private

  def document_class
    NewsArticle
  end
end
