class RemoveDefaultNewsOrganisationImageDataFromOrganisations < ActiveRecord::Migration[7.0]
  def change
    remove_column :organisations, :default_news_organisation_image_data_id, :integer
  end
end
