class Admin::PolicyAdvisoryGroupsController < Admin::BaseController
  before_filter :enforce_permissions!, only: [:destroy]

  def index
    @policy_advisory_groups = PolicyAdvisoryGroup.order(:name)
  end

  def new
    @policy_advisory_group = PolicyAdvisoryGroup.new
  end

  def create
    @policy_advisory_group = PolicyAdvisoryGroup.new(params[:policy_advisory_group])
    if @policy_advisory_group.save
      redirect_to admin_policy_advisory_groups_path, notice: %{"#{@policy_advisory_group.name}" created.}
    else
      render action: "new"
    end
  end

  def edit
    @policy_advisory_group = PolicyAdvisoryGroup.find(params[:id])
  end

  def update
    @policy_advisory_group = PolicyAdvisoryGroup.find(params[:id])
    if @policy_advisory_group.update_attributes(params[:policy_advisory_group])
      redirect_to admin_policy_advisory_groups_path, notice: %{"#{@policy_advisory_group.name}" saved.}
    else
      render action: "edit"
    end
  end

  def destroy
    policy_advisory_group = PolicyAdvisoryGroup.find(params[:id])
    name = policy_advisory_group.name
    policy_advisory_group.destroy
    redirect_to admin_policy_advisory_groups_path, notice: %{"#{name}" deleted.}
  end

private
  def enforce_permissions!
    enforce_permission!(:delete, PolicyAdvisoryGroup)
  end
end
