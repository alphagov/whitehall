class Api::SpecialistGuidesController < PublicFacingController
  respond_to :json

  def show
    if @guide = SpecialistGuide.published_as(params[:id])
      respond_with Api::SpecialistGuidePresenter.decorate(@guide)
    else
      render json: 'Not Found', status: :not_found
    end
  end

  def index
  end
end