class HomeController < PublicFacingController
  def show
    find_featured_news_articles
    @recently_updated = Edition.published.by_published_at.limit(10)
  end

  def sunset
  end

  def tour
  end

  private

  def find_featured_news_articles
    @featured_news_articles = NewsArticle.published.featured.by_first_published_at.limit(3).includes(:document, :edition_relations, :topics)
  end
end