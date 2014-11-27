class AddContentIdToWorldLocations < ActiveRecord::Migration
  def change
    add_column :world_locations, :content_id, :string
  end
end
