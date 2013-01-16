class PolicyAdvisoryGroupsController < PublicFacingController
  def index
    @policy_advisory_groups = PolicyAdvisoryGroup.all.order(:name)
  end

  def show
    @policy_advisory_group = PolicyAdvisoryGroup.find(params[:id])
    @policies = @policy_advisory_group.policies.published.in_reverse_chronological_order
  end
end
