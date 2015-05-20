class PolicyGroupsController < PublicFacingController
  def index
    @policy_groups = PolicyGroup.order(:name)
  end

  def show
    @policy_group = PolicyGroup.friendly.find(params[:id])
    @policies = @policy_group.published_policies

    set_meta_description(@policy_group.summary)
  end
end
