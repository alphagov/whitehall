class RenameCountriesToWorldLocations < ActiveRecord::Migration
  def change
    rename_table :countries, :world_locations

    rename_index "world_locations", "index_countries_on_slug", "index_world_locations_on_slug"
  end
end
