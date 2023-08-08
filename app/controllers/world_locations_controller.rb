class WorldLocationsController < PublicFacingController
  enable_request_formats index: [:json]

  def index
    respond_to do |format|
      format.any do
        @world_locations = WorldLocation.all_by_type
      end
    end
  end
end
