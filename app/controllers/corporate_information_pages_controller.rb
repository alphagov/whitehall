class CorporateInformationPagesController < PublicFacingController
  before_filter :find_organisation

  def show
    @corporate_information_page = @organisation.corporate_information_pages.for_slug!(params[:id])
    set_slimmer_organisations_header([@corporate_information_page.organisation])
  end

  private

  def find_organisation
    @organisation  = case params.keys.grep(/(.+)_id$/).first.to_sym
    when :organisation_id
      Organisation.find(params[:organisation_id])
    when :worldwide_organisation_id
      WorldwideOrganisation.find(params[:worldwide_organisation_id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
