class AddAnalyticsIdentifierToWorldLocations < ActiveRecord::Migration
  def change
    add_column :world_locations, :analytics_identifier, :string
  end

  def migrate(direction)
    super

    if direction == :up
      WorldLocation.all.each do |location|
        location.update_column :analytics_identifier, WorldLocation.analytics_prefix + location.id.to_s
      end
    end
  end
end
