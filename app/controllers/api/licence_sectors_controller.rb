class Api::LicenceSectorsController < PublicFacingController
  skip_before_action :restrict_request_formats
  before_action :set_api_cache_control_headers
  before_action :set_api_access_control_allow_origin_headers

  respond_to :json

  self.responder = Api::Responder

  def index
    respond_with Api::LicenceSectorsPresenter.paginate(Sector.where(parent_sector_id: nil), view_context)
  end

  def show
    @sector = Sector.find_by(id: params[:id])

    if @sector
      respond_with Api::LicenceSectorsPresenter.new(@sector, view_context)
    else
      respond_with_not_found
    end
  end

private

  def respond_with_not_found
    respond_with({}, status: :not_found)
  end
end
