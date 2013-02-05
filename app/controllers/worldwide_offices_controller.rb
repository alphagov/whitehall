class WorldwideOfficesController < PublicFacingController
  include CacheControlHelper

  respond_to :html

  def show
    expires_in 5.minutes, public: true
    respond_with @worldwide_office = WorldwideOffice.find(params[:id])
  end
end
