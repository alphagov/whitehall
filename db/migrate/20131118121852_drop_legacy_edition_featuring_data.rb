class DropLegacyEditionFeaturingData < ActiveRecord::Migration
  def change
    remove_columns :edition_organisations, :featured, :alt_text, :ordering, :edition_organisation_image_data_id
    drop_table :edition_organisation_image_data
  end
end
