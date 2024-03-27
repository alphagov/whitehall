class Admin::WorldwideOrganisationPagesController < Admin::BaseController
  before_action :find_worldwide_organisation

  def index; end

private

  def find_worldwide_organisation
    @worldwide_organisation = Edition.find(params[:editionable_worldwide_organisation_id])
  end
end
