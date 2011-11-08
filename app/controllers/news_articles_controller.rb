class NewsArticlesController < DocumentsController
  def show
    @related_policies = Policy.published.related_to(@document)
  end

  private

  def document_class
    NewsArticle
  end
end