class RemoveEmbassyFieldsFromWorldLocations < ActiveRecord::Migration
  def change
    remove_column :world_locations, :embassy_address
    remove_column :world_locations, :embassy_telephone
    remove_column :world_locations, :embassy_email
  end
end
