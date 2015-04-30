class WorldwideOfficesController < PublicFacingController
  before_filter :load_worldwide_organisation

  def show
    @worldwide_office = @worldwide_organisation.offices.find(params[:id])
  end

  private

  def load_worldwide_organisation
    @worldwide_organisation = WorldwideOrganisation.friendly.find(params[:worldwide_organisation_id])
  end
end
