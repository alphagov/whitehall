class Admin::EditionWorldLocationsController < Admin::BaseController
  def update
    edition_world_location = EditionWorldLocation.find(params[:id])
    edition_world_location.update_attributes(params[:edition_world_location])
    redirect_to edit_admin_world_location_path(edition_world_location.world_location)
  end
end
