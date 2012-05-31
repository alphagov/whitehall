class Admin::PolicyTopicsController < Admin::BaseController
  layout "bootstrap_admin"

  before_filter :default_arrays_of_ids_to_empty, only: [:update]

  def index
    @policy_topics = PolicyTopicsPresenter.new
  end

  def new
    @policy_topic = PolicyTopic.new
  end

  def create
    @policy_topic = PolicyTopic.new(params[:policy_topic])
    if @policy_topic.save
      redirect_to admin_policy_topics_path, notice: "Policy topic created"
    else
      render action: "new"
    end
  end

  def edit
    @policy_topic = PolicyTopic.find(params[:id])
  end

  def update
    @policy_topic = PolicyTopic.find(params[:id])
    if @policy_topic.update_attributes(params[:policy_topic])
      redirect_to admin_policy_topics_path, notice: "Policy topic updated"
    else
      render action: "edit"
    end
  end

  def feature
    @policy_topic = PolicyTopic.find(params[:id])
    if @policy_topic.published_policies.any?
      @policy_topic.feature
      redirect_to admin_policy_topics_path, notice: "The policy topic #{@policy_topic.name} is now featured"
    else
      redirect_to admin_policy_topics_path, alert: "The policy topic #{@policy_topic.name} cannot be featured because it has no published policies"
    end
  end

  def unfeature
    @policy_topic = PolicyTopic.find(params[:id])
    @policy_topic.unfeature
    redirect_to admin_policy_topics_path, notice: "The policy topic #{@policy_topic.name} is no longer featured"
  end

  def destroy
    @policy_topic = PolicyTopic.find(params[:id])
    @policy_topic.delete!
    if @policy_topic.deleted?
      redirect_to admin_policy_topics_path, notice: "Policy topic destroyed"
    else
      redirect_to admin_policy_topics_path, alert: "Cannot destroy policy topic with associated content"
    end
  end

  class PolicyTopicsPresenter < Whitehall::Presenters::Collection
    def initialize
      super(PolicyTopic.order(:name))
    end

    present_object_with do
      def breakdown
        published_policy_ids = @record.policies.published.select("editions.id")
        {
          "featured policy" => @record.policy_topic_memberships.where(featured: true).where("policy_id IN (?)", published_policy_ids).count,
          "published policy" => published_policy_ids.count
        }
      end
    end
  end

  private

  def default_arrays_of_ids_to_empty
    params[:policy_topic][:related_policy_topic_ids] ||= []
  end
end
