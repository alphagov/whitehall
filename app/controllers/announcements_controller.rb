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
    news_today = NewsArticle.published.not_featured.by_published_at.where(
      'published_at > :time', time: 1.day.ago).includes(:document_identity, :document_relations, :policy_areas)
    speeches_today = Speech.published.by_published_at.where(
      'published_at > :time', time: 1.day.ago).includes(:document_identity, role_appointment: [:person, :role])

    (news_today + speeches_today).sort_by!{|a| a.published_at }.reverse
  end

  def announced_in_last_7_days
    news_this_week = NewsArticle.published.not_featured.by_published_at.where(published_at: 1.week.ago .. 24.hours.ago).includes(:document_identity, :document_relations, :policy_areas)
    speeches_this_week = Speech.published.by_published_at.where(published_at: 1.week.ago .. 24.hours.ago).includes(:document_identity, role_appointment: [:person, :role])

    (news_this_week + speeches_this_week).sort_by!{|a| a.published_at }.reverse
  end
end