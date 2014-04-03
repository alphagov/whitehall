class Admin::PolicyGroupsController < Admin::BaseController
  before_filter :enforce_permissions!, only: [:destroy]

  def index
    @policy_groups = PolicyGroup.order(:name)
  end

  def new
    @policy_group = PolicyGroup.new
  end

  def create
    @policy_group = PolicyGroup.new(policy_group_params)
    if @policy_group.save
      redirect_to admin_policy_groups_path, notice: %{"#{@policy_group.name}" created.}
    else
      render action: "new"
    end
  end

  def edit
    @policy_group = PolicyGroup.find(params[:id])
  end

  def update
    @policy_group = PolicyGroup.find(params[:id])
    if @policy_group.update_attributes(policy_group_params)
      redirect_to admin_policy_groups_path, notice: %{"#{@policy_group.name}" saved.}
    else
      render action: "edit"
    end
  end

  def destroy
    policy_group = PolicyGroup.find(params[:id])
    name = policy_group.name
    policy_group.destroy
    redirect_to admin_policy_groups_path, notice: %{"#{name}" deleted.}
  end

private
  def enforce_permissions!
    enforce_permission!(:delete, PolicyGroup)
  end

  def policy_group_params
    params.require(:policy_group).permit(
      :name, :email, :summary, :description
    )
  end
end
