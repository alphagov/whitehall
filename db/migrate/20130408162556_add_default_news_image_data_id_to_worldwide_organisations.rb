class AddDefaultNewsImageDataIdToWorldwideOrganisations < ActiveRecord::Migration
  def change
    add_column :worldwide_organisations, :default_news_organisation_image_data_id, :integer
    add_index :worldwide_organisations, :default_news_organisation_image_data_id, name: "index_worldwide_organisations_on_image_data_id"
  end
end
