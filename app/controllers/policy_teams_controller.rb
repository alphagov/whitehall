class PolicyTeamsController < PublicFacingController
  def show
    @policy_team = PolicyTeam.find(params[:id])
    @policies = @policy_team.policies.published.by_published_at
  end
end
