class AnnouncementsController < PublicFacingController

  before_filter :load_announced_today, only: [:index]
  before_filter :load_announced_in_last_7_days, only: [:index]

  def index
    @featured_news_articles = NewsArticle.published.by_published_at.where(featured: true).includes(:document_identity, :document_relations, :policy_areas)
  end

  def load_announced_today
    news_today = NewsArticle.published.by_published_at.where(
      'published_at > :time && featured = false', time: 1.day.ago).includes(:document_identity, :document_relations, :policy_areas)

    speeches_today = Speech.published.by_published_at.where(
      'published_at > :time && featured = false', time: 1.day.ago).includes(:document_identity, role_appointment: [:person, :role])

    @announced_today = (news_today + speeches_today).sort_by!{|a| a.published_at }.reverse
  end

  def load_announced_in_last_7_days
    news_this_week = NewsArticle.published.by_published_at.where(featured: false, published_at: 1.week.ago .. 24.hours.ago).includes(:document_identity, :document_relations, :policy_areas)
    speeches_this_week = Speech.published.by_published_at.where(featured: false, published_at: 1.week.ago .. 24.hours.ago).includes(:document_identity, role_appointment: [:person, :role])
    @announced_in_last_7_days = (news_this_week + speeches_this_week).sort_by!{|a| a.published_at }.reverse
  end
end