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

  def feature
    @topic = Topic.find(params[:id])
    @topic.update_attributes(featured: true)
    redirect_to admin_topics_path, notice: "The topic #{@topic.name} is now featured"
  end

  def unfeature
    @topic = Topic.find(params[:id])
    @topic.update_attributes(featured: false)
    redirect_to admin_topics_path, notice: "The topic #{@topic.name} is no longer featured"
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