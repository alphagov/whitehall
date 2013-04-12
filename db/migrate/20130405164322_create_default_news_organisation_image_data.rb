class CreateDefaultNewsOrganisationImageData < ActiveRecord::Migration
  def change
    create_table :default_news_organisation_image_data do |t|
      t.string :carrierwave_image
      t.timestamps
    end
    add_column :organisations, :default_news_organisation_image_data_id, :integer
    add_index :organisations, :default_news_organisation_image_data_id
  end
end
