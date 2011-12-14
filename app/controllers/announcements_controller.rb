class AnnouncementsController < ApplicationController
  def index
    @featured_news_articles = NewsArticle.published.featured.by_published_at.limit(3)
    @announcements = find_announcements
  end

  protected

  def find_announcements
    speeches = Speech.published.by_published_at
    news_articles = NewsArticle.published.by_published_at

    ((news_articles - @featured_news_articles) + speeches).sort_by!{|a| a.published_at }.reverse
  end
end