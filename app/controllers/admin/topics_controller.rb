class Admin::TopicsController < Admin::BaseController
  before_filter :default_arrays_of_ids_to_empty, only: [:update]

  def index
    @topics = TopicsPresenter.by_name
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
    @topic.delete!
    if @topic.deleted?
      redirect_to admin_topics_path, notice: "Topic destroyed"
    else
      redirect_to admin_topics_path, alert: "Cannot destroy topic with associated content"
    end
  end

  class TopicsPresenter < Draper::Base
    class << self
      def by_name
        decorate Topic.order(:name)
      end
    end

    def breakdown
      published_policy_ids = policies.published.select("editions.id")
      {
        "published policy" => published_policy_ids.count,
        "published detailed guide" => detailed_guides.published.count
      }
    end
  end

  private

  def default_arrays_of_ids_to_empty
    params[:topic][:related_topic_ids] ||= []
  end
end
