class WorldwideOrganisationsController < PublicFacingController
  include CacheControlHelper
  before_filter :load_worldwide_organisation, only: :show

  respond_to :html

  def show
    expires_in 5.minutes, public: true
    @world_locations = @worldwide_organisation.world_locations
    @main_office = @worldwide_organisation.main_office
    @other_offices = @worldwide_organisation.other_offices
    @primary_role = primary_role
    @other_roles = ([secondary_role] + office_roles).compact

    respond_with @worldwide_organisation
  end

  private

  def load_worldwide_organisation
    @worldwide_organisation = WorldwideOrganisation.with_translations(I18n.locale).find(params[:id])
  end

  def primary_role
    RolePresenter.new(@worldwide_organisation.primary_role) if @worldwide_organisation.primary_role
  end

  def secondary_role
    RolePresenter.new(@worldwide_organisation.secondary_role) if @worldwide_organisation.secondary_role
  end

  def office_roles
    @worldwide_organisation.office_staff_roles.collect { |office_staff| RolePresenter.new(office_staff) }
  end
end
