class Admin::DocumentCountriesController < Admin::BaseController
  def update
    document_country = EditionCountry.find(params[:id])
    document_country.update_attributes(params[:edition_country])
    redirect_to edit_admin_country_path(document_country.country)
  end
end