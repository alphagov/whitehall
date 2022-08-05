class Api::LicenceSectorsController < PublicFacingController
  skip_before_action :restrict_request_formats
  before_action :set_api_cache_control_headers
  before_action :set_api_access_control_allow_origin_headers

  respond_to :json

  self.responder = Api::Responder

  def index
    respond_with Api::LicenceSectorsPresenter.paginate(Sector.where(parent_sector_id: nil), view_context)
  end
end
