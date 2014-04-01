class PolicyGroupsController < PublicFacingController
  def index
    @policy_groups = PolicyGroup.order(:name)
  end

  def show
    @policy_group = PolicyGroup.find(params[:id])
    @policies = @policy_group.policies.published.in_reverse_chronological_order

    set_meta_description(@policy_group.summary)
  end
end
