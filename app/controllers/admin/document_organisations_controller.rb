class Admin::DocumentOrganisationsController < Admin::BaseController
  def update
    document_organisation = DocumentOrganisation.find(params[:id])
    document_organisation.update_attributes(params[:document_organisation])
    redirect_to edit_admin_organisation_path(document_organisation.organisation_id)
  end
end