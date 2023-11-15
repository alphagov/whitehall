class RemoveDefaultNewsOrganisationImageDataFromWorldwideOrganisations < ActiveRecord::Migration[7.0]
  def change
    remove_column :worldwide_organisations, :default_news_organisation_image_data_id, :integer
  end
end
