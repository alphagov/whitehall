class Api::SpecialistGuidesController < PublicFacingController
  respond_to :json

  def show
    @guide = SpecialistGuide.published_as(params[:id])
    if @guide
      respond_with Api::SpecialistGuidePresenter.new(@guide)
    else
      render json: { _response_info: { status: "not found" } }, status: :not_found
    end
  end

  def index
    respond_with Api::SpecialistGuidePresenter.paginate(
      SpecialistGuide.published.alphabetical
    )
  end
end
