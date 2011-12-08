class AnnouncementsController < ApplicationController
  def index
    @news_articles = NewsArticle.published.by_published_at
    @featured_news_articles = NewsArticle.published.featured.by_published_at.limit(3)
    @speeches = Speech.published.by_published_at
  end
end