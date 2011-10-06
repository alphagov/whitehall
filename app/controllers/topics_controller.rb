class TopicsController < ApplicationController
  def index
    @topics = Topic.with_published_documents
  end

  def show
    @topic = Topic.find(params[:id])
  end
end