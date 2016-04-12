class PolicyGroupsController < PublicFacingController
  def index
    @policy_groups = PolicyGroup.order(:name)
  end

  def show
    @policy_group = PolicyGroup.friendly.find(params[:id])

    #return 301 and redirect in case a URL uses the group's ID rather than slug
    if params[:id] != @policy_group.to_param
      redirect_to @policy_group, status: :moved_permanently
    else
      @policies = @policy_group.published_policies
      set_meta_description(@policy_group.summary)
    end
  end
end
