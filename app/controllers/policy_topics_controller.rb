class PolicyTopicsController < PublicFacingController
  def index
    @policy_topics = PolicyTopic.all
    @featured_policy_topics = PolicyTopic.featured.order("updated_at DESC").limit(3)
  end

  def show
    @policy_topic = PolicyTopic.find(params[:id])
    @exemplary_policy_topics = PolicyTopic.exemplars
    @policies = @policy_topic.policies.published
    @related_policy_topics = @policy_topic.related_policy_topics
    @recently_changed_documents = recently_changed_documents
    @featured_policies = FeaturedPolicyPresenter.new(@policy_topic)
  end

  class FeaturedPolicyPresenter < Whitehall::Presenters::Collection
    def initialize(policy_topic)
      super(policy_topic.featured_policies)
    end
  end

  private

  def recently_changed_documents
    (@policy_topic.published_related_editions + @policies).sort_by(&:published_at).reverse
  end
end
