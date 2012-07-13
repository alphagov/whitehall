class PolicyTeamsController < PublicFacingController
  def index
    @policy_teams = PolicyTeam.all.sort_by { |o| o.name }
  end

  def show
    @policy_team = PolicyTeam.find(params[:id])
    @policies = @policy_team.policies.published.by_published_at
  end
end
