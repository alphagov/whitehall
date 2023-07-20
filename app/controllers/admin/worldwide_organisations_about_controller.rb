class Admin::WorldwideOrganisationsAboutController < Admin::BaseController
  layout "design_system"

  def show
    @worldwide_organisation = WorldwideOrganisation.friendly.find(params[:id])
  end
end
