class TopicsController < ApplicationController
  def index
    @topics = Topic.with_published_documents
  end

  def show
    @topic = Topic.find(params[:id])
    load_published_documents_in_scope { |scope| scope.in_topic(@topic) }
  end
end