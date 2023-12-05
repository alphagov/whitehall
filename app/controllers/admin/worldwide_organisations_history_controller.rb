class Admin::WorldwideOrganisationsHistoryController < Admin::BaseController
  def index
    @worldwide_organisation = LegacyWorldwideOrganisation.friendly.find(params[:id])
    @versions = @worldwide_organisation
              .versions_desc
              .page(params[:page])
              .per(Admin::LegacyWorldwideOrganisationsController::VERSIONS_PER_PAGE)
  end
end
