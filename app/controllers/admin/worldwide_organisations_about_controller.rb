class Admin::WorldwideOrganisationsAboutController < Admin::BaseController
  def show
    @worldwide_organisation = WorldwideOrganisation.friendly.find(params[:id])
  end
end
