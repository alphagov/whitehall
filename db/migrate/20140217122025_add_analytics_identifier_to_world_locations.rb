class AddAnalyticsIdentifierToWorldLocations < ActiveRecord::Migration
  def change
    add_column :world_locations, :analytics_identifier, :string
  end
end
