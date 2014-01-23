class Admin::PolicyTeamsController < Admin::BaseController
  def index
    @policy_teams = PolicyTeam.order(:name)
  end

  def new
    @policy_team = PolicyTeam.new
  end

  def create
    @policy_team = PolicyTeam.new(policy_team_params)
    if @policy_team.save
      redirect_to admin_policy_teams_path, notice: %{"#{@policy_team.name}" created.}
    else
      render action: "new"
    end
  end

  def edit
    @policy_team = PolicyTeam.find(params[:id])
  end

  def update
    @policy_team = PolicyTeam.find(params[:id])
    if @policy_team.update_attributes(policy_team_params)
      redirect_to admin_policy_teams_path, notice: %{"#{@policy_team.name}" saved.}
    else
      render action: "edit"
    end
  end

private
  def policy_team_params
    params.require(:policy_team).permit(:name, :email, :description)
  end
end
