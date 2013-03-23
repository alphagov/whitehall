puts "Adding Chad and Mauritania to WorldLocations."
country_type = WorldLocationType::WorldLocation
WorldLocation.create(name: 'Chad', title: 'UK in Chad', iso2: 'td', world_location_type: country_type)
WorldLocation.create(name: 'Mauritania', title: 'UK in Mauritania', iso2: 'mr', world_location_type: country_type)

puts "Deleting duplicate locations..."
%w(
    uk-joint-delegation-to-nato-north-atlantic-treaty-organization
    uk-delegation-to-osce-vienna-organization-for-security-and-co-operation-in-europe
    uk-delegation-to-council-of-europe--2
    uk-representation-to-the-un-conference-on-disarmament-in-geneva
    uk-mission-geneva
    uk-representation-to-the-eu-european-union
    united-kingdom-mission-to-united-nations-in-vienna
  ).each do |slug|
    if location = WorldLocation.where(slug: slug).first
      puts "Deleting #{location.name}."
      location.destroy
    else
      puts "Location with slug '#{slug}' not found."
    end
end
