class WorldwideOrganisationsController < PublicFacingController
  include CacheControlHelper
  before_filter :load_worldwide_organisation, only: :show

  respond_to :html, :json

  def show
    respond_to do |format|
      format.json { redirect_to api_worldwide_organisation_path(@worldwide_organisation, format: :json) }
      format.html do
        expires_in 5.minutes, public: true
        @world_locations = @worldwide_organisation.world_locations
        @main_office = main_office
        @other_offices = other_offices
        @primary_role = primary_role
        @other_roles = ([secondary_role] + office_roles).compact
      end
    end
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

  def main_office
    ContactPresenter.new(@worldwide_organisation.main_office) if @worldwide_organisation.main_office
  end

  def other_offices
    @worldwide_organisation.other_offices.map { |o| ContactPresenter.new(o) }
  end
end
