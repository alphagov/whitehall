class Api::DetailedGuidesController < PublicFacingController
  respond_to :json

  self.responder = Api::Responder

  def show
    @guide = DetailedGuide.published_as(params[:id])
    if @guide
      respond_with Api::DetailedGuidePresenter.new(@guide)
    else
      respond_with_not_found
    end
  end

  def index
    respond_with Api::DetailedGuidePresenter.paginate(
      DetailedGuide.published.alphabetical
    )
  end

  private

  def respond_with_not_found
    respond_with Hash.new, status: :not_found
  end
end
