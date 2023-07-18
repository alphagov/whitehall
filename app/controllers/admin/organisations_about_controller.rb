class Admin::OrganisationsAboutController < Admin::BaseController
  layout "design_system"

  def show
    @organisation = Organisation.friendly.find(params[:id])
  end
end
