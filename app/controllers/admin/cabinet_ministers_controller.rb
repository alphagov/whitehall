class Admin::CabinetMinistersController < Admin::BaseController
  before_action :enforce_permissions!

  def show
    @cabinet_minister_roles = MinisterialRole.includes(:translations).where(cabinet_member: true).order(:seniority)
    @also_attends_cabinet_roles = MinisterialRole.includes(:translations).also_attends_cabinet.order(:seniority)
    @whip_roles = MinisterialRole.includes(:translations).whip.order(:whip_ordering)
    @organisations = Organisation.ministerial_departments.excluding_govuk_status_closed.order(:ministerial_ordering)
  end

  def reorder_cabinet_minister_roles
    @roles = MinisterialRole.includes(:translations).where(cabinet_member: true).order(:seniority)
  end

  def order_cabinet_minister_roles
    params["ordering"].each do |id, ordering|
      Role.find(id).update_column(:seniority, ordering)
    end

    redirect_to admin_cabinet_ministers_path(anchor: "cabinet_minister")
  end

  def reorder_also_attends_cabinet_roles
    @roles = MinisterialRole.includes(:translations).also_attends_cabinet.order(:seniority)
  end

  def order_also_attends_cabinet_roles
    params["ordering"].each do |id, ordering|
      Role.find(id).update_column(:seniority, ordering)
    end

    redirect_to admin_cabinet_ministers_path(anchor: "also_attends_cabinet")
  end

  def reorder_whip_roles
    @roles = MinisterialRole.includes(:translations).whip.order(:whip_ordering)
  end

  def order_whip_roles
    params["ordering"].each do |id, ordering|
      Role.find(id).update_column(:whip_ordering, ordering)
    end

    redirect_to admin_cabinet_ministers_path(anchor: "whips")
  end

  def reorder_ministerial_organisations
    @organisations = Organisation.ministerial_departments.excluding_govuk_status_closed.order(:ministerial_ordering)
  end

  def order_ministerial_organisations
    params["ordering"].each do |id, ordering|
      Organisation.find(id).update_column(:ministerial_ordering, ordering)
    end

    redirect_to admin_cabinet_ministers_path(anchor: "organisations")
  end

private

  def enforce_permissions!
    enforce_permission!(:reorder_cabinet_ministers, MinisterialRole)
  end
end
