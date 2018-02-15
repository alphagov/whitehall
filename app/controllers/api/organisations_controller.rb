class Api::OrganisationsController < PublicFacingController
  skip_before_action :restrict_request_formats
  respond_to :json

  self.responder = Api::Responder

  def index
    respond_with Api::OrganisationPresenter.paginate(
      # Need to order by something for pagination to be deterministic:
      Organisation.includes(:parent_organisations, :child_organisations, :translations,
        :superseding_organisations, :superseded_organisations).order(:id),
      view_context
    )
  end

  def show
    @organisation = Organisation.friendly.find(params[:id])
    if @organisation
      respond_with Api::OrganisationPresenter.new(@organisation, view_context)
    else
      respond_with_not_found
    end
  end

private

  def respond_with_not_found
    respond_with Hash.new, status: :not_found
  end
end
