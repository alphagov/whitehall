class TopicsController < ApplicationController
  def show
    @topic = Topic.find(params[:id])
  end
end