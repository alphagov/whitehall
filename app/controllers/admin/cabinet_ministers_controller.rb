class Admin::CabinetMinistersController < Admin::BaseController

  before_action :enforce_permissions!

  def show
    @cabinet_minister_roles = MinisterialRole.includes(:translations).where(cabinet_member: true).order(:seniority)
    @also_attends_cabinet_roles = MinisterialRole.includes(:translations).also_attends_cabinet.order(:seniority)
    @whip_roles = MinisterialRole.includes(:translations).whip.order(:whip_ordering)
    @organisations = Organisation.ministerial_departments.excluding_govuk_status_closed.order(:ministerial_ordering)
  end

  def update
    update_ordering(:roles, :seniority)
    update_ordering(:whips, :whip_ordering)
    update_organisation_ordering

    redirect_to admin_cabinet_ministers_path
  end

private

  def enforce_permissions!
    enforce_permission!(:reorder_cabinet_ministers, MinisterialRole)
  end

  def update_ordering(key, column)
    return unless params.include?(key)
    params[key].keys.each do |id|
      Role.where(id: id).update_all(
        column => params[key]["#{id}"]["ordering"],
      )
    end
  end

  def update_organisation_ordering
    return unless params.include?(:organisation)
    params[:organisation].each_pair do |id, org_params|
      Organisation.find(id).update_attributes(
        ministerial_ordering: org_params["ordering"]
      )
    end
  end
end
