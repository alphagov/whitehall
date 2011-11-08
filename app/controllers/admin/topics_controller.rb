class Admin::TopicsController < Admin::BaseController
  def index
    @topics = Topic.all
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(params[:topic])
    if @topic.save
      redirect_to admin_topics_path, notice: "Topic created"
    else
      render action: "new"
    end
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(params[:topic])
      redirect_to admin_topics_path, notice: "Topic updated"
    else
      render action: "edit"
    end
  end

  def destroy
    @topic = Topic.find(params[:id])
    if @topic.destroy
      redirect_to admin_topics_path, notice: "Topic destroyed"
    else
      redirect_to admin_topics_path, alert: "Cannot destroy topic with associated content"
    end
  end
end