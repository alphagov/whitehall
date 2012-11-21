class PolicyTeamsController < PublicFacingController
  def index
    @policy_teams = PolicyTeam.all.sort_by { |o| o.name }
  end

  def show
    @policy_team = PolicyTeam.find(params[:id])
    @policies = @policy_team.policies.published.in_reverse_chronological_order
  end
end
