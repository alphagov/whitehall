class Api::WorldLocationsController < PublicFacingController
  include WorldLocationHelper

  skip_before_action :set_cache_control_headers
  skip_before_action :restrict_request_formats
  before_action :set_api_cache_control_headers
  before_action :set_api_access_control_allow_origin_headers
  respond_to :json

  self.responder = Api::Responder

  def show
    @world_location = WorldLocation.find_by(slug: params[:id])
    if @world_location
      respond_with Api::WorldLocationPresenter.new(@world_location, view_context)
    else
      respond_with_not_found
    end
  end

  def index
    respond_with Api::WorldLocationPresenter.paginate(
      Kaminari.paginate_array(sorted_world_locations),
      view_context
    )
  end

private

  def respond_with_not_found
    respond_with Hash.new, status: :not_found
  end

  def sorted_world_locations
    group_and_sort(WorldLocation.ordered_by_name)
      .flat_map { |_, locations| locations }
  end
end
