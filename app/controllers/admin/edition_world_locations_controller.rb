class Admin::EditionWorldLocationsController < Admin::BaseController
  before_filter :find_world_location
  before_filter :find_edition_world_location, except: :index
  before_filter :limit_edition_world_location_access!, except: :index

  def index
    @featured_editions = @world_location.featured_edition_world_locations
    @editions = @world_location.published_edition_world_locations
  end

  def edit
    @edition_world_location.featured = true
    @edition_world_location.build_image
  end

  def update
    attributes = params[:edition_world_location]
    if attributes[:featured] == "false"
      attributes[:image] = nil
      attributes[:alt_text] = nil
    end
    if @edition_world_location.update_attributes(attributes)
      redirect_to admin_world_location_featurings_path(@edition_world_location.world_location)
    else
      @edition_world_location.build_image unless @edition_world_location.image.present?
      render :edit
    end
  end

  private
  def find_world_location
    @world_location = WorldLocation.find(params[:world_location_id])
  end

  def find_edition_world_location
    @edition_world_location = @world_location.edition_world_locations.find(params[:id])
  end

  def limit_edition_world_location_access!
    unless @edition_world_location.edition.accessible_by?(current_user)
      render "admin/editions/forbidden", status: 403
    end
  end
end
