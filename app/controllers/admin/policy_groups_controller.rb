class Admin::PolicyGroupsController < Admin::BaseController
  before_action :enforce_permissions!, only: %i[confirm_destroy destroy]
  before_action :load_group, only: %i[edit update confirm_destroy destroy]
  layout :get_layout

  def index
    @policy_groups = PolicyGroup.order(:name)
    render_design_system("index", "legacy_index", next_release: false)
  end

  def new
    @policy_group = PolicyGroup.new
  end

  def create
    @policy_group = PolicyGroup.new(policy_group_params)
    if @policy_group.save
      redirect_to admin_policy_groups_path, notice: %("#{@policy_group.name}" created.)
    else
      render action: "new"
    end
  end

  def edit; end

  def update
    if @policy_group.update(policy_group_params)
      redirect_to admin_policy_groups_path, notice: %("#{@policy_group.name}" saved.)
    else
      render action: "edit"
    end
  end

  def confirm_destroy; end

  def destroy
    name = @policy_group.name
    @policy_group.destroy!
    redirect_to admin_policy_groups_path, notice: %("#{name}" deleted.)
  end

private

  def get_layout
    design_system_actions = []
    design_system_actions += %w[index confirm_destroy] if preview_design_system?(next_release: false)

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

  def load_group
    @policy_group = PolicyGroup.friendly.find(params[:id])
  end

  def enforce_permissions!
    enforce_permission!(:delete, PolicyGroup)
  end

  def policy_group_params
    params.require(:policy_group).permit(
      :name, :email, :summary, :description
    )
  end
end
