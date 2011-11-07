class NewsArticlesController < DocumentsController
  def index
    @articles = NewsArticle.published.newest_first
  end

  def show
    @related_policies = Policy.published.related_to(@document)
  end

  private

  def document_class
    NewsArticle
  end
end