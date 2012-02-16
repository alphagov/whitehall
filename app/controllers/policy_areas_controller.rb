class PolicyAreasController < PublicFacingController
  def index
    @policy_areas = PolicyArea.all
    @featured_policy_areas = PolicyArea.featured.order("updated_at DESC").limit(3)
  end

  def show
    @policy_area = PolicyArea.find(params[:id])
    @policies = @policy_area.policies.published
    @related_policy_areas = @policy_area.related_policy_areas
    @recently_changed_documents = recently_changed_documents
    @featured_policies = FeaturedPolicyPresenter.new(@policy_area)
  end

  class FeaturedPolicyPresenter < Whitehall::Presenters::Collection
    def initialize(policy_area)
      super(policy_area.featured_policies)
    end
  end

  private

  def recently_changed_documents
    (@policy_area.published_related_documents + @policies).sort_by(&:published_at).reverse
  end
end