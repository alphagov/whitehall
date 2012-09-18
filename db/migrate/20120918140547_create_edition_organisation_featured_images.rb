class CreateEditionOrganisationFeaturedImages < ActiveRecord::Migration
  def up
    create_table :edition_organisation_image_data, force: true do |t|
      t.string :carrierwave_image
      t.timestamps
    end

    add_column :edition_organisations, :edition_organisation_image_data_id, :integer
  end

  def down
    remove_column :edition_organisations, :edition_organisation_image_data_id
    drop_table :edition_organisation_image_data
  end
end