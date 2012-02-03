class AnnouncementsController < PublicFacingController

  def index
    @featured_news_articles = featured_news_articles
    @announced_in_last_7_days = announced_in_last_7_days
    @announced_today = announced_today
    @announced_today_featured = @announced_today.select { |a| a.respond_to?(:image) && a.image.present? }.take(3)
    @announced_today_not_featured = @announced_today - @announced_today_featured
  end

  private

  def featured_news_articles
    NewsArticle.published.featured.by_first_published_at.limit(3).includes(:document_identity, :document_relations, :policy_areas)
  end

  def announced_today
    today = 1.day.ago
    news_today = NewsArticle.published.first_published_since(today).not_featured.
      by_first_published_at.includes(:document_identity, :document_relations, :policy_areas)
    speeches_today = Speech.published.first_published_since(today).
      by_first_published_at.includes(:document_identity, role_appointment: [:person, :role])

    Announcement.by_first_published_at(news_today + speeches_today)
  end

  def announced_in_last_7_days
    this_week = 1.week.ago..1.day.ago
    news_this_week = NewsArticle.published.first_published_during(this_week).not_featured.
      by_first_published_at.includes(:document_identity, :document_relations, :policy_areas)
    speeches_this_week = Speech.published.first_published_during(this_week).
      by_first_published_at.includes(:document_identity, role_appointment: [:person, :role])

    Announcement.by_first_published_at(news_this_week + speeches_this_week)
  end
end