class UserWorldLocations < ActiveRecord::Migration
  def change
    create_table :user_world_locations do |t|
      t.references :user
      t.references :world_location
    end

    add_index :user_world_locations, [:user_id, :world_location_id], unique: true
  end
end
