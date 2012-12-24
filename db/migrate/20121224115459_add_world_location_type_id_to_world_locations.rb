class AddWorldLocationTypeIdToWorldLocations < ActiveRecord::Migration
  def change
    # two stages: 1. add the column as nullable
    add_column :world_locations, :world_location_type_id, :integer
    # 2. use change_column_null to set make it null false and
    # set the existing nulls to 1
    change_column_null :world_locations, :world_location_type_id, false, 1
    add_index :world_locations, :world_location_type_id
  end
end
