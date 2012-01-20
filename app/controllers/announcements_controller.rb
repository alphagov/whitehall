class AnnouncementsController < PublicFacingController

  def index
    @featured_news_articles = featured_news_articles
    @announced_in_last_7_days = announced_in_last_7_days
    @announced_today = announced_today
  end

  def featured_news_articles
    NewsArticle.published.featured.by_published_at.limit(3).includes(:document_identity, :document_relations, :policy_areas)
  end

  def announced_today
    today = 1.day.ago
    news_today = NewsArticle.published.published_since(today).not_featured.
      by_published_at.includes(:document_identity, :document_relations, :policy_areas)
    speeches_today = Speech.published.published_since(today).
      by_published_at.includes(:document_identity, role_appointment: [:person, :role])

    (news_today + speeches_today).sort_by!{|a| a.published_at }.reverse
  end

  def announced_in_last_7_days
    this_week = 1.week.ago..1.day.ago
    news_this_week = NewsArticle.published.published_during(this_week).not_featured.
      by_published_at.includes(:document_identity, :document_relations, :policy_areas)
    speeches_this_week = Speech.published.published_during(this_week).
      by_published_at.includes(:document_identity, role_appointment: [:person, :role])

    (news_this_week + speeches_this_week).sort_by!{|a| a.published_at }.reverse
  end
end