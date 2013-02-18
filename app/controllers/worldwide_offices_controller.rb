class WorldwideOfficesController < PublicFacingController
  include CacheControlHelper
  before_filter :load_worldwide_office, only: :show

  respond_to :html

  def show
    expires_in 5.minutes, public: true
    @world_locations = @worldwide_office.world_locations
    @main_contact = @worldwide_office.main_contact
    @other_contacts = @worldwide_office.other_contacts
    @primary_role = primary_role
    @other_roles = ([secondary_role] + office_roles).compact

    respond_with @worldwide_office
  end

  private

  def load_worldwide_office
    @worldwide_office = WorldwideOffice.with_translations(I18n.locale).find(params[:id])
  end

  def primary_role
    RolePresenter.new(@worldwide_office.primary_role) if @worldwide_office.primary_role
  end

  def secondary_role
    RolePresenter.new(@worldwide_office.secondary_role) if @worldwide_office.secondary_role
  end

  def office_roles
    @worldwide_office.office_staff_roles.collect { |office_staff| RolePresenter.new(office_staff) }
  end
end
