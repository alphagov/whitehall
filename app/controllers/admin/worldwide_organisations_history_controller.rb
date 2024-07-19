class Admin::WorldwideOrganisationsHistoryController < Admin::BaseController
  def index
    @worldwide_organisation = WorldwideOrganisation.friendly.find(params[:id])
    @versions = @worldwide_organisation
              .versions_desc
              .page(params[:page])
              .per(Admin::WorldwideOrganisationsController::VERSIONS_PER_PAGE)
  end
end
