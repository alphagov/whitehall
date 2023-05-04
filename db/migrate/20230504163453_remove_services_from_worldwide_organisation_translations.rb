class RemoveServicesFromWorldwideOrganisationTranslations < ActiveRecord::Migration[7.0]
  def change
    remove_column :worldwide_organisation_translations, :services, :text
  end
end
