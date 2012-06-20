class Admin::EditionOrganisationsController < Admin::BaseController
  def update
    edition_organisation = EditionOrganisation.find(params[:id])
    edition_organisation.update_attributes(params[:edition_organisation])
    redirect_to admin_organisation_path(edition_organisation.organisation)
  end
end
