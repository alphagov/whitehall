class NewsArticlesController < DocumentsController
  before_filter :set_analytics_format, only: [:show]

  def show
    @related_policies = @document.published_related_policies
    @document = NewsArticlePresenter.new(@document, view_context)
    set_meta_description(@document.summary)
  end

  private

  def document_class
    NewsArticle
  end

  def analytics_format
    :news
  end
end
