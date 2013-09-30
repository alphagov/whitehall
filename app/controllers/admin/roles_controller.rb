class Admin::RolesController < Admin::BaseController
  before_filter :load_role, only: [:edit, :update, :destroy]

  def index
    @roles = Role.includes(:role_appointments, :current_people, :translations, organisations: [:translations]).
                  order("organisation_translations.name, roles.type DESC, roles.permanent_secretary DESC, role_translations.name")
  end

  def new
    @role = MinisterialRole.new(cabinet_member: true)
  end

  def create
    attributes = RoleTypePresenter.role_attributes_from(params[:role])
    @role = Role.new(attributes.except(:type))
    @role.type = attributes.delete(:type) || MinisterialRole.name
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
    attributes = RoleTypePresenter.role_attributes_from(params[:role])
    if new_type = attributes.delete(:type)
      @role.type = new_type
    end
    if @role.update_attributes(attributes)
      redirect_to admin_roles_path, notice: %{"#{@role.name}" updated.}
    else
      render action: "edit"
    end
  end

  def destroy
    notice = %{"#{@role.name}" destroyed.}
    if @role.destroy
      redirect_to admin_roles_path, notice: notice
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
