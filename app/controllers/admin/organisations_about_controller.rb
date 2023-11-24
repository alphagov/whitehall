class Admin::OrganisationsAboutController < Admin::BaseController
  def show
    @organisation = Organisation.friendly.find(params[:id])
  end
end
