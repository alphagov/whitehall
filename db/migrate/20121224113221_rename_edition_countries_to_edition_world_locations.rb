class RenameEditionCountriesToEditionWorldLocations < ActiveRecord::Migration
  def change
    rename_table :edition_countries, :edition_world_locations
    rename_column :edition_world_locations, :country_id, :world_location_id

    rename_index "edition_world_locations", "index_edition_countries_on_country_id", "index_edition_world_locations_on_world_location_id"
    rename_index "edition_world_locations", "index_edition_countries_on_edition_id", "index_edition_world_locations_on_edition_id"
  end
end
