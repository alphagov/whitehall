class TopicsController < ApplicationController
  def index
    @topics = Topic.with_published_documents
  end

  def show
    @topic = Topic.find(params[:id])
    @policies = @topic.published_policies
    @news_articles = @topic.published_news_articles
  end
end