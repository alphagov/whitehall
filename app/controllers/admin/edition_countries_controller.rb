class Admin::EditionCountriesController < Admin::BaseController
  def update
    edition_country = EditionCountry.find(params[:id])
    edition_country.update_attributes(params[:edition_country])
    redirect_to edit_admin_country_path(edition_country.country)
  end
end
