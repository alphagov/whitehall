class Admin::PolicyAreasController < Admin::BaseController
  def index
    @topics = PolicyAreasPresenter.new
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(params[:topic])
    if @topic.save
      redirect_to admin_topics_path, notice: "Policy area created"
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
      redirect_to admin_topics_path, notice: "Policy area updated"
    else
      render action: "edit"
    end
  end

  def feature
    @topic = Topic.find(params[:id])
    @topic.update_attributes(featured: true)
    redirect_to admin_topics_path, notice: "The policy area #{@topic.name} is now featured"
  end

  def unfeature
    @topic = Topic.find(params[:id])
    @topic.update_attributes(featured: false)
    redirect_to admin_topics_path, notice: "The policy area #{@topic.name} is no longer featured"
  end

  def destroy
    @topic = Topic.find(params[:id])
    if @topic.destroy
      redirect_to admin_topics_path, notice: "Policy area destroyed"
    else
      redirect_to admin_topics_path, alert: "Cannot destroy policy area with associated content"
    end
  end

  class PolicyAreasPresenter < Whitehall::Presenters::Collection
    def initialize
      super(Topic.all)
    end

    present_object_with do
      def document_breakdown
        {
          "featured policy" => @record.document_topics.where(featured: true).count,
          "published policy" => @record.policies.published.count,
          "published document" => @record.published_documents.count
        }
      end
    end
  end
end