class Admin::GroupsController < Admin::BaseController
  before_filter :load_group, only: [:edit, :update, :destroy]

  def index
    @groups = Group.includes(:organisation).order("organisations.name, groups.name")
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(params[:group])
    if @group.save
      redirect_to admin_groups_path, notice: %{"#{@group.name}" created.}
    else
      render action: "new"
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    if @group.update_attributes(params[:group])
      redirect_to admin_groups_path, notice: %{"#{@group.name}" updated.}
    else
      render action: "edit"
    end
  end

  def destroy
    if @group.destroy
      redirect_to admin_groups_path, notice: %{"#{@group.name}" destroyed.}
    else
      message = "Cannot destroy a group with memberships or organisation"
      redirect_to admin_groups_path, alert: message
    end
  end

  private

  def load_group
    @group = Group.find(params[:id])
  end

end
