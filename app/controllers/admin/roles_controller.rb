class Admin::RolesController < Admin::BaseController
  before_filter :load_role, only: [:edit, :update, :destroy]

  def index
    @roles = Role.includes(:organisations, :people).order("organisations.name, roles.type DESC, roles.leader DESC, roles.name")
  end

  def new
    @role = Role.new
    @role.role_appointments.build
  end

  def create
    @role = Role.new(params[:role].except(:role_appointments_attributes, :type))
    @role.type = params[:role][:type] || MinisterialRole.name
    if @role.save
      if @role.update_attributes(params[:role])
        redirect_to admin_roles_path, notice: %{"#{@role.name}" created.}
      else
        render action: "edit"
      end
    else
      @role.role_appointments_attributes = params[:role][:role_appointments_attributes]
      @role.role_appointments.build if @role.role_appointments.all?(&:persisted?)
      render action: "new"
    end
  end

  def edit
    @role = Role.find(params[:id])
    @role.role_appointments.build
  end

  def update
    params[:role][:organisation_ids] ||= []
    params[:role][:role_appointments_attributes] ||= {}
    if new_type = params[:role].delete(:type)
      @role.type = new_type
    end
    if @role.update_attributes(params[:role])
      redirect_to admin_roles_path, notice: %{"#{@role.name}" updated.}
    else
      @role.role_appointments.build if @role.role_appointments.all?(&:persisted?)
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