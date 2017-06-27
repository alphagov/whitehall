all_world_locations = WorldLocation.all

all_world_locations.each do |world_location|
  world_location.save
end
