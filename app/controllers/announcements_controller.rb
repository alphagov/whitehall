class AnnouncementsController < ApplicationController
  def index
    @news_articles = NewsArticle.published.by_publication_date
    @featured_news_articles = NewsArticle.published.featured.by_publication_date.limit(3)
    @speeches = Speech.published.by_publication_date
  end
end