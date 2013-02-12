class WorldwideOfficesController < PublicFacingController
  include CacheControlHelper

  respond_to :html

  def show
    expires_in 5.minutes, public: true
    @worldwide_office = WorldwideOffice.find(params[:id])
    @world_locations = @worldwide_office.world_locations
    @main_contact = @worldwide_office.main_contact
    @other_contacts = @worldwide_office.other_contacts
    @primary_role = primary_role
    @secondary_role = secondary_role
    @supporting_appointments = supporting_appointments

    respond_with @worldwide_office
  end

  private

  def primary_role
    RolePresenter.new(@worldwide_office.primary_role) if @worldwide_office.primary_role
  end

  def secondary_role
    RolePresenter.new(@worldwide_office.secondary_role) if @worldwide_office.secondary_role
  end

  def supporting_appointments
    @worldwide_office.worldwide_office_appointments.collect do |appointment|
      WorldwideOfficeAppointmentPresenter.new(appointment)
    end
  end
end
