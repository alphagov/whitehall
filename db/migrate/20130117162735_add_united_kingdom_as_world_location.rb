class AddUnitedKingdomAsWorldLocation < ActiveRecord::Migration
  class WorldLocation < ActiveRecord::Base; end

  def up
    WorldLocation.create!(name: "United Kingdom", iso2: "GB", world_location_type_id: WorldLocationType::WorldLocation.id)
  end

  def down
    WorldLocation.find_by_name("United Kingdom").destroy
  end
end
