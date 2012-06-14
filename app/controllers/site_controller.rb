class SiteController < PublicFacingController
  def index
    find_featured_news_articles
    @recently_updated = Edition.published.by_published_at.limit(10)
  end

  def sunset
  end

  def tour
  end

  def grid
  end

  def sha
    skip_slimmer
    render text: `git rev-parse HEAD`
  end

  def headers
    @headers = request.headers.select {|k,v| k.starts_with?("HTTP_") }
  end

  private

  def find_featured_news_articles
    @featured_news_articles = NewsArticle.published.featured.by_first_published_at.limit(3).includes(:document, :edition_relations, :topics)
  end
end
