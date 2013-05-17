class Api::WorldwideOrganisationsController < PublicFacingController
  respond_to :json

  self.responder = Api::Responder

  def show
    @worldwide_organisation = WorldwideOrganisation.find_by_slug(params[:id])
    if @worldwide_organisation
      respond_with Api::WorldwideOrganisationPresenter.new(@worldwide_organisation, view_context)
    else
      respond_with_not_found
    end
  end

  def index
    if world_location
      respond_with Api::WorldwideOrganisationPresenter.paginate(
        world_location.worldwide_organisations,
        view_context
      )
    else
      respond_with_not_found
    end
  end

  private

  def respond_with_not_found
    respond_with Hash.new, status: :not_found
  end

  def world_location
    @world_location ||= WorldLocation.find_by_slug(params[:world_location_id])
  end
end
