class Admin::DocumentOrganisationsController < Admin::BaseController
  def update
    document_organisation = EditionOrganisation.find(params[:id])
    document_organisation.update_attributes(params[:edition_organisation])
    redirect_to edit_admin_organisation_path(document_organisation.organisation)
  end
end