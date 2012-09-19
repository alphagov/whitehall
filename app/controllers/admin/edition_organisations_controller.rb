class Admin::EditionOrganisationsController < Admin::BaseController
  def edit
    @edition_organisation = EditionOrganisation.find(params[:id])
    @edition_organisation.featured = true
    @edition_organisation.build_image
  end

  def update
    @edition_organisation = EditionOrganisation.find(params[:id])
    attributes = params[:edition_organisation]
    if attributes[:featured] == "false"
      attributes[:image] = nil
      attributes[:alt_text] = nil
    end
    if @edition_organisation.update_attributes(attributes)
      redirect_to admin_organisation_path(@edition_organisation.organisation, anchor: "documents")
    else
      @edition_organisation.build_image unless @edition_organisation.image.present?
      render :edit
    end
  end
end
