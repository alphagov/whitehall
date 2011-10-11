class TopicsController < ApplicationController
  def index
    @topics = Topic.with_published_documents
  end

  def show
    @topic = Topic.find(params[:id])
    @policies = @topic.published_policies
    @publications = @topic.published_publications
  end
end