class CorporateInformationPagesController < PublicFacingController
  def show
    @organisation = Organisation.find(params[:organisation_id])
    @corporate_information_page = @organisation.corporate_information_pages.for_slug!(params[:id])
    set_slimmer_organisations_header([@corporate_information_page.organisation])
  end
end
