class AssociateWorldwideOfficesWithWorldLocations < ActiveRecord::Migration
  def change
    create_table "worldwide_office_world_locations" do |t|
      t.integer  "worldwide_office_id"
      t.integer  "world_location_id"
      t.timestamps
    end
    add_index "worldwide_office_world_locations", "worldwide_office_id"
    add_index "worldwide_office_world_locations", "world_location_id"
  end
end