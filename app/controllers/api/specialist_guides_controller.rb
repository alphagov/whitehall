class Api::SpecialistGuidesController < PublicFacingController
  respond_to :json

  def show
    if @guide = SpecialistGuide.published_as(params[:id])
      respond_with Api::SpecialistGuidePresenter.new(@guide)
    else
      render json: 'Not Found', status: :not_found
    end
  end

  def index
    respond_with Api::SpecialistGuidePresenter.paginate(
      SpecialistGuide.published.alphabetical
    )
  end
end