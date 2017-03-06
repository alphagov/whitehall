class NewsArticlesController < DocumentsController
  before_filter :set_analytics_format, only: [:show]

  private

  def analytics_format
    :news
  end
end
