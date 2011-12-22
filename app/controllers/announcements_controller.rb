class AnnouncementsController < ApplicationController
  def index
    speeches = Speech.published.by_published_at.includes(:document_identity, role_appointment: [:person, :role])
    news_articles = NewsArticle.published.by_published_at.includes(:document_identity, :document_relations, :policy_areas)

    @featured_news_articles = news_articles.select { |news_article| news_article.featured? }[0...3]
    @announcements = ((news_articles - @featured_news_articles) + speeches).sort_by!{|a| a.published_at }.reverse
  end
end