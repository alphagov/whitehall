class Admin::PolicyTeamsController < Admin::BaseController
  def index
    @policy_teams = PolicyTeam.order(:email)
  end

  def new
    @policy_team = PolicyTeam.new
  end

  def create
    @policy_team = PolicyTeam.new(params[:policy_team])
    if @policy_team.save
      redirect_to admin_policy_teams_path, notice: %{"#{@policy_team.email}" created.}
    else
      render action: "new"
    end
  end

  def edit
    @policy_team = PolicyTeam.find(params[:id])
  end

  def update
    @policy_team = PolicyTeam.find(params[:id])
    if @policy_team.update_attributes(params[:policy_team])
      redirect_to admin_policy_teams_path, notice: %{"#{@policy_team.email}" saved.}
    else
      render action: "edit"
    end
  end
end
