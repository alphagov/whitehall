class RenameWorldLocationTypeId < ActiveRecord::Migration[7.0]
  def change
    rename_column :world_locations, :world_location_type_id, :world_location_type
  end
end
