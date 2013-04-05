class Admin::CabinetMinistersController < Admin::BaseController

  def show
    @cabinet_minister_roles = MinisterialRole.includes(:translations).where(cabinet_member: true).order(:seniority)
  end

  def update
    role_ids = params[:roles].keys
    role_ids.each do |role|
      #update attributes resaves the whole model
      Role.where(id: role).update_all :seniority => params[:roles]["#{role}"]["ordering"]
    end
    redirect_to admin_cabinet_ministers_path
  end
end