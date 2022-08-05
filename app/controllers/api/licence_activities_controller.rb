class Api::LicenceActivitiesController < PublicFacingController
  skip_before_action :restrict_request_formats
  before_action :set_api_cache_control_headers
  before_action :set_api_access_control_allow_origin_headers

  respond_to :json

  self.responder = Api::Responder

  def index
    respond_with Api::LicenceActivitiesPresenter.paginate(Activity.order(:title), view_context)
  end

  def show
    @activity = Activity.find_by(id: params[:id])

    if @activity
      respond_with Api::LicenceActivitiesPresenter.new(@activity, view_context)
    else
      respond_with_not_found
    end
  end

private

  def respond_with_not_found
    respond_with({}, status: :not_found)
  end
end
