class CorporateInformationPagesController < PublicFacingController
  before_filter :find_organisation

  def show
    @corporate_information_page = @organisation.corporate_information_pages.for_slug!(params[:id])
    set_slimmer_organisations_header([@corporate_information_page.organisation])
    set_slimmer_page_owner_header(@corporate_information_page.organisation)
    if @organisation.is_a? WorldwideOrganisation
      render 'show_worldwide_organisation'
    else
      render :show
    end
  end

private

  def find_organisation
    @organisation =
      if params.has_key?(:organisation_id)
        Organisation.find(params[:organisation_id])
      elsif params.has_key?(:worldwide_organisation_id)
        WorldwideOrganisation.find(params[:worldwide_organisation_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end
end
