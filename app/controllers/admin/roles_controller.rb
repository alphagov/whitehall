class Admin::RolesController < Admin::BaseController
  def index
    @roles = Role.order(:name)
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      redirect_to admin_roles_path, notice: %{"#{@role.name}" created.}
    else
      render action: "new"
    end
  end
end