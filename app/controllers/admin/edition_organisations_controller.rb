class Admin::EditionOrganisationsController < Admin::BaseController
  before_filter :find_edition_organisation
  before_filter :limit_edition_organisation_access!

  def edit
    @edition_organisation.featured = true
    @edition_organisation.build_image
  end

  def update
    attributes = params[:edition_organisation]
    if attributes[:featured] == "false"
      attributes[:image] = nil
      attributes[:alt_text] = nil
    end
    if @edition_organisation.update_attributes(attributes)
      redirect_to documents_admin_organisation_path(@edition_organisation.organisation)
    else
      @edition_organisation.build_image unless @edition_organisation.image.present?
      render :edit
    end
  end

private

  def find_edition_organisation
    @edition_organisation = EditionOrganisation.find(params[:id])
  end

  def limit_edition_organisation_access!
    unless @edition_organisation.edition.accessible_by?(current_user)
      render "admin/editions/forbidden", status: 403
    end
  end

end
