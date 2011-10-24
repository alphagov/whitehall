class Admin::TopicsController < Admin::BaseController
  def index
    @topics = Topic.all
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(params[:topic])
      redirect_to admin_topics_path, alert: "Topic updated"
    else
      render action: "edit"
    end
  end
end