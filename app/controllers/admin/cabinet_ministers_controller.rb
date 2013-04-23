class Admin::CabinetMinistersController < Admin::BaseController

  before_filter :enforce_permissions!

  def show
    @cabinet_minister_roles = MinisterialRole.includes(:translations).where(cabinet_member: true).order(:seniority)
    @also_attends_cabinet_roles = MinisterialRole.includes(:translations).also_attends_cabinet.order(:seniority)
  end

  def update
    role_ids = params[:roles].keys
    role_ids.each do |role|
      Role.where(id: role).update_all seniority: params[:roles]["#{role}"]["ordering"]
    end
    redirect_to admin_cabinet_ministers_path
  end

private
  def enforce_permissions!
    enforce_permission!(:reorder_cabinet_ministers, MinisterialRole)
  end

end
