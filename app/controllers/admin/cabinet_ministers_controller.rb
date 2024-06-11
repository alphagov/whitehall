class Admin::CabinetMinistersController < Admin::BaseController
  include ReshuffleMode
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
    MinisterialRole.reorder_without_callbacks!(order_ministerial_roles_params, :seniority)
    republish_ministers_index_page_to_publishing_api

    redirect_to admin_cabinet_ministers_path(anchor: "cabinet_minister")
  end

  def reorder_also_attends_cabinet_roles
    @roles = MinisterialRole.includes(:translations).also_attends_cabinet.order(:seniority)
  end

  def order_also_attends_cabinet_roles
    MinisterialRole.reorder_without_callbacks!(order_ministerial_roles_params, :seniority)
    republish_ministers_index_page_to_publishing_api

    redirect_to admin_cabinet_ministers_path(anchor: "also_attends_cabinet")
  end

  def reorder_whip_roles
    @roles = MinisterialRole.includes(:translations).whip.order(:whip_ordering)
  end

  def order_whip_roles
    MinisterialRole.reorder_without_callbacks!(order_ministerial_roles_params, :whip_ordering)
    republish_ministers_index_page_to_publishing_api

    redirect_to admin_cabinet_ministers_path(anchor: "whips")
  end

  def reorder_ministerial_organisations
    @organisations = Organisation.ministerial_departments.excluding_govuk_status_closed.order(:ministerial_ordering)
  end

  def order_ministerial_organisations
    Organisation.reorder_without_callbacks!(order_ministerial_organisations_params, :ministerial_ordering)
    republish_ministers_index_page_to_publishing_api

    redirect_to admin_cabinet_ministers_path(anchor: "organisations")
  end

private

  def enforce_permissions!
    enforce_permission!(:reorder_cabinet_ministers, MinisterialRole)
  end

  def order_ministerial_roles_params
    params.require(:ministerial_roles)["ordering"]
  end

  def order_ministerial_organisations_params
    params.require(:ministerial_organisations)["ordering"]
  end
end
