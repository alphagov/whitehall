class Admin::CabinetMinistersController < Admin::BaseController
  before_action :enforce_permissions!
  layout "design_system"

  def show
    @cabinet_minister_roles = MinisterialRole.includes(:translations).where(cabinet_member: true).order(:seniority)
    @also_attends_cabinet_roles = MinisterialRole.includes(:translations).also_attends_cabinet.order(:seniority)
    @whip_roles = MinisterialRole.includes(:translations).whip.order(:whip_ordering)
    @organisations = Organisation.ministerial_departments.excluding_govuk_status_closed.order(:ministerial_ordering)
  end

  def reorder_cabinet_minister_roles
    @roles = MinisterialRole.includes(:translations).where(cabinet_member: true).order(:seniority)
  end

  def reorder_also_attends_cabinet_roles
    @roles = MinisterialRole.includes(:translations).also_attends_cabinet.order(:seniority)
  end

  def reorder_whip_roles
    @roles = MinisterialRole.includes(:translations).whip.order(:whip_ordering)
  end

  def reorder_ministerial_organisations
    @organisations = Organisation.ministerial_departments.excluding_govuk_status_closed.order(:ministerial_ordering)
  end

  def update
    update_ordering(:roles, :seniority)
    update_ordering(:whips, :whip_ordering)
    update_organisation_ordering

    redirect_to admin_cabinet_ministers_path + add_anchor_if_arrived_from_reorder_page
  end

private

  def enforce_permissions!
    enforce_permission!(:reorder_cabinet_ministers, MinisterialRole)
  end

  def add_anchor_if_arrived_from_reorder_page
    return "" if request.referer.blank?

    case URI(request.referer).path
    when reorder_cabinet_minister_roles_admin_cabinet_ministers_path
      "#cabinet_minister"
    when reorder_also_attends_cabinet_roles_admin_cabinet_ministers_path
      "#also_attends_cabinet"
    when reorder_whip_roles_admin_cabinet_ministers_path
      "#whips"
    when reorder_ministerial_organisations_admin_cabinet_ministers_path
      "#organisations"
    else
      ""
    end
  end

  def update_ordering(key, column)
    return unless params.include?(key)

    params[key]["ordering"].keys.each do |id|
      Role.where(id:).update_all("#{column}": params[key]["ordering"][id.to_s])
    end
  end

  def update_organisation_ordering
    return unless params.include?(:organisation)

    params[:organisation]["ordering"].each_pair do |id, order|
      Organisation.where(id:).update_all(
        ministerial_ordering: order,
      )
    end
  end
end
