class Admin::PolicyAdvisoryGroupsController < Admin::BaseController
  def index
    @policy_advisory_groups = PolicyAdvisoryGroup.order(:name)
  end

  def new
    @policy_advisory_group = PolicyAdvisoryGroup.new
    build_attachment
  end

  def create
    @policy_advisory_group = PolicyAdvisoryGroup.new(params[:policy_advisory_group])
    if @policy_advisory_group.save
      redirect_to admin_policy_advisory_groups_path, notice: %{"#{@policy_advisory_group.email}" created.}
    else
      render action: "new"
    end
  end

  def edit
    @policy_advisory_group = PolicyAdvisoryGroup.find(params[:id])
    build_attachment
  end

  def update
    @policy_advisory_group = PolicyAdvisoryGroup.find(params[:id])
    if @policy_advisory_group.update_attributes(params[:policy_advisory_group])
      redirect_to admin_policy_advisory_groups_path, notice: %{"#{@policy_advisory_group.email}" saved.}
    else
      render action: "edit"
    end
  end

  private

  def build_attachment
    @policy_advisory_group.build_empty_attachment
  end
end
