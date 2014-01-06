class RemoveUnusedEditionWorldLocationColumns < ActiveRecord::Migration
  def up
    drop_table :edition_world_location_image_data

    remove_index :edition_world_locations, name: 'idx_edition_world_locs_on_edition_world_location_image_data_id'

    remove_column :edition_world_locations, :featured
    remove_column :edition_world_locations, :ordering
    remove_column :edition_world_locations, :edition_world_location_image_data_id
    remove_column :edition_world_locations, :alt_text
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
