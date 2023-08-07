class WorldLocationsController < PublicFacingController
  enable_request_formats index: [:json]

  def index
    respond_to do |format|
      format.any do
        @world_locations = WorldLocation.all_by_type
        set_meta_description("Help and services in a country")
      end
    end
  end
end
