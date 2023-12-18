class Admin::OrganisationPeopleController < Admin::BaseController
  before_action :load_organisation
  before_action :enforce_permissions!, only: %i[reorder order]

  def index
    @render_reorder = can?(:edit, @organisation)
    @ministerial_organisation_roles = organisation_roles("ministerial")
    @management_organisation_roles = organisation_roles("management")
    @traffic_commissioner_organisation_roles = organisation_roles("traffic_commissioner")
    @military_organisation_roles = organisation_roles("military")
    @special_representative_organisation_roles = organisation_roles("special_representative")
    @chief_professional_officer_roles = organisation_roles("chief_professional_officer")
  end

  def reorder
    type = params[:type]
    valid_types = %w[ministerial special_representative management traffic_commissioner chief_professional_officer military]

    if valid_types.exclude?(type)
      render "admin/errors/not_found", status: :not_found
    else
      @organisation_roles = organisation_roles(type)
    end
  end

  def order
    @organisation.organisation_roles.reorder!(order_params)
    Whitehall::PublishingApi.republish_async(@organisation)

    redirect_to admin_organisation_people_path(@organisation), notice: "#{params[:type].capitalize.gsub('_', ' ')} roles re-ordered"
  end

private

  def organisation_roles(type)
    @organisation
    .organisation_roles
    .joins(:role)
    .merge(roles_for_type(type))
    .order(:ordering)
  end

  def roles_for_type(type)
    case type
    when "ministerial"
      Role.ministerial
    when "management"
      Role.management
    when "traffic_commissioner"
      Role.traffic_commissioner
    when "military"
      Role.military
    when "special_representative"
      Role.special_representative
    when "chief_professional_officer"
      Role.chief_professional_officer
    end
  end

  def enforce_permissions!
    enforce_permission!(:edit, @organisation)
  end

  def load_organisation
    @organisation = Organisation.friendly.find(params[:organisation_id])
  end

  def order_params
    params.require(:organisation_people)["ordering"]
  end
end
