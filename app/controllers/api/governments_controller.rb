class Api::GovernmentsController < PublicFacingController
  skip_before_action :restrict_request_formats
  respond_to :json

  self.responder = Api::Responder

  def index
    respond_with Api::GovernmentPresenter.paginate(Government.order(start_date: :desc), view_context)
  end

  def show
    @government = Government.find_by(slug: params[:id])
    if @government
      respond_with Api::GovernmentPresenter.new(@government, view_context)
    else
      respond_with_not_found
    end
  end

private

  def respond_with_not_found
    respond_with Hash.new, status: :not_found
  end
end
