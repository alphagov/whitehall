class AnnouncementsController < ApplicationController
  def index
    @news_articles = NewsArticle.published.by_publication_date
    @speeches = Speech.published.by_publication_date
  end
end