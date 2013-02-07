class WorldwideOfficesController < PublicFacingController
  include CacheControlHelper

  respond_to :html

  def show
    expires_in 5.minutes, public: true
    @worldwide_office = WorldwideOffice.find(params[:id])
    @main_contact = @worldwide_office.main_contact
    @other_contacts = @worldwide_office.other_contacts
    respond_with @worldwide_office
  end
end
