class Admin::OrganisationPeopleController < Admin::BaseController
  before_action :load_organisation
  before_action :enforce_permissions!, only: %i[reorder order]
  layout "design_system"

  def index
    @render_reorder = can?(:edit, @organisation)
    @ministerial_organisation_roles = organisation_roles(:ministerial)
    @management_organisation_roles = organisation_roles(:management)
    @traffic_commissioner_organisation_roles = organisation_roles(:traffic_commissioner)
    @military_organisation_roles = organisation_roles(:military)
    @special_representative_organisation_roles = organisation_roles(:special_representative)
    @chief_professional_officer_roles = organisation_roles(:chief_professional_officer)
  end

  def reorder
    type = params[:type]
    @organisation_roles = organisation_roles(type)
  end

  def order
    params[:ordering].each do |organisation_role_id, ordering|
      @organisation.organisation_roles.find(organisation_role_id).update_column(:ordering, ordering)
    end

    redirect_to admin_organisation_people_path(@organisation), notice: "#{params[:type].capitalize.gsub('_', ' ')} roles re-ordered"
  end

  private

  def organisation_roles(type)
    @organisation.organisation_roles.joins(:role)
                 .merge(Role.send(type)).order(:ordering)
  end

  def enforce_permissions!
    enforce_permission!(:edit, @organisation)
  end

  def load_organisation
    @organisation = Organisation.friendly.find(params[:organisation_id])
  end
end
