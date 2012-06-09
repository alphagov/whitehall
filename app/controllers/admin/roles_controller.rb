class Admin::RolesController < Admin::BaseController
  before_filter :load_role, only: [:edit, :update, :destroy]

  def index
    @roles = Role.includes(:organisations, :role_appointments, :current_people).order("organisations.name, roles.type DESC, roles.permanent_secretary DESC, roles.name")
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(params[:role].except(:type))
    @role.type = params[:role].delete(:type) || MinisterialRole.name
    if @role.save
      redirect_to admin_roles_path, notice: %{"#{@role.name}" created.}
    else
      render action: "new"
    end
  end

  def edit
    @role = Role.find(params[:id])
  end

  def update
    params[:role][:organisation_ids] ||= []
    if new_type = params[:role].delete(:type)
      @role.type = new_type
    end
    if @role.update_attributes(params[:role])
      redirect_to admin_roles_path, notice: %{"#{@role.name}" updated.}
    else
      render action: "edit"
    end
  end

  def destroy
    if @role.destroy
      redirect_to admin_roles_path, notice: %{"#{@role.name}" destroyed.}
    else
      message = "Cannot destroy a role with appointments, organisations, or documents"
      redirect_to admin_roles_path, alert: message
    end
  end

  private

  def load_role
    @role = Role.find(params[:id])
  end
end
