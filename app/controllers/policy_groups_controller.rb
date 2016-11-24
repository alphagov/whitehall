class PolicyGroupsController < PublicFacingController
  def show
    # Routes matching /policy/[ID] still fall through to Whitehall rather than
    # government-frontend. We redirect them.
    # Return 301 and redirect in case a URL uses the group's ID rather than slug
    @policy_group = PolicyGroup.friendly.find(params[:id])
    if params[:id] != @policy_group.to_param
      redirect_to @policy_group, status: :moved_permanently
    end
  end
end
