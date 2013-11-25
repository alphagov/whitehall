class Api::WorldLocationsController < PublicFacingController
  skip_before_filter :restrict_request_formats
  respond_to :json

  self.responder = Api::Responder

  def show
    @world_location = WorldLocation.find_by_slug(params[:id])
    if @world_location
      respond_with Api::WorldLocationPresenter.new(@world_location, view_context)
    else
      respond_with_not_found
    end
  end

  def index
    respond_with Api::WorldLocationPresenter.paginate(
      WorldLocation.ordered_by_name,
      view_context
    )
  end

  private

  def respond_with_not_found
    respond_with Hash.new, status: :not_found
  end
end
