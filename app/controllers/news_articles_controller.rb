class NewsArticlesController < DocumentsController
  def index
    @news_articles = NewsArticle.published.by_publication_date
  end

  def show
    @related_policies = Policy.published.related_to(@document)
  end

  private

  def document_class
    NewsArticle
  end
end