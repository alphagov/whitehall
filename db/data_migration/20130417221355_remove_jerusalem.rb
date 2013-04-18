location = WorldLocation.find_by_slug('jerusalem')

if location
  location.destroy
  puts "Removed location"
end
