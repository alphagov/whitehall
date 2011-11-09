class TopicsController < ApplicationController
  def index
    @topics = Topic.with_published_documents
    @featured_topic = Topic.featured.first
  end

  def show
    @topic = Topic.find(params[:id])
    @policies = @topic.policies.published
    @news_articles = @topic.news_articles.published
  end
end