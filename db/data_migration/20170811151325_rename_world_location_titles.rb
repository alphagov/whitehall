WorldLocation.where(world_location_type_id: 1).each do |world_location|
  new_title = "#{world_location.name} and the UK"
  puts "Update title for #{world_location.name} to '#{new_title}'"
  world_location.title = new_title
  world_location.save!
end
