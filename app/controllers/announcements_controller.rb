class AnnouncementsController < PublicFacingController

  def index
    @featured_news_articles = featured_news_articles
    @announced = AnnouncementPresenter.new
  end

  private

  def featured_news_articles
    NewsArticle.published.featured.by_first_published_at.limit(3).includes(:document_identity, :document_relations, :policy_areas)
  end
end