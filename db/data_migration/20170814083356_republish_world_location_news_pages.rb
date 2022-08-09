WorldLocation.where(world_location_type_id: 1).each do |world_location|
  puts "Republishing news page for #{world_location.name}"
  WorldLocationNewsWorker.new.perform(world_location.id)
end
