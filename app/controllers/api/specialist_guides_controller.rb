class Api::SpecialistGuidesController < PublicFacingController
  respond_to :json

  self.responder = Api::Responder

  def show
    @guide = SpecialistGuide.published_as(params[:id])
    if @guide
      respond_with Api::SpecialistGuidePresenter.new(@guide)
    else
      respond_with_not_found
    end
  end

  def index
    respond_with Api::SpecialistGuidePresenter.paginate(
      SpecialistGuide.published.alphabetical
    )
  end

  private

  def respond_with_not_found
    respond_with Hash.new, status: :not_found
  end
end
