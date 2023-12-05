class Admin::WorldwideOrganisationsAboutController < Admin::BaseController
  def show
    @worldwide_organisation = LegacyWorldwideOrganisation.friendly.find(params[:id])
  end
end
