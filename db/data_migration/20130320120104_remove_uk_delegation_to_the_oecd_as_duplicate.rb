location_to_keep = WorldLocation.find('the-uk-permanent-delegation-to-the-oecd-organisation-for-economic-co-operation-and-development')
location_to_destroy = WorldLocation.find('uk-delegation-to-the-oecd')

# copy edition->location matches
print "Copying #{location_to_destroy.name} editions over to #{location_to_keep.name}: "
location_to_destroy.edition_world_locations.each do |edition_world_location|
  unless location_to_keep.editions.include? edition_world_location.edition
    edition_world_location.update_column(:world_location_id, location_to_keep.id)
    print '.'
  end
end
puts 'Done!'

# copy mainstream links -> location matches
print "Copying #{location_to_destroy.name} mainstream links over to #{location_to_keep.name}: "
location_to_destroy.world_location_mainstream_links.each do |world_location_mainstream_link|
  unless location_to_keep.mainstream_links.include? world_location_mainstream_link.mainstream_link
    world_location_mainstream_link.update_column(:world_location_id, location_to_keep.id)
    print '.'
  end
end
puts 'Done!'

# copy world org -> location matches
print "Copying #{location_to_destroy.name} worldwide organisations over to #{location_to_keep.name}: "
location_to_destroy.worldwide_organisation_world_locations.each do |worldwide_organisation_world_location|
  unless location_to_keep.worldwide_organisations.include? worldwide_organisation_world_location.worldwide_organisation
    worldwide_organisation_world_location.update_column(:world_location_id, location_to_keep.id)
    print '.'
  end
end
puts 'Done!'

# copy user -> location matches
print "Copying #{location_to_destroy.name} users over to #{location_to_keep.name}: "
UserWorldLocation.where(world_location_id: location_to_destroy.id).each do |user_world_location|
  unless UserWorldLocation.where(world_location_id: location_to_keep.id).map(&:user_id).include? user_world_location.user_id
    user_world_location.update_column(:world_location_id, location_to_keep.id)
    print '.'
  end
end
puts 'Done!'

# copy contact locations over
print "Copying #{location_to_destroy.name} contacts over to #{location_to_keep.name}: "
Contact.where(country_id: location_to_destroy.id).each do |contact|
  contact.update_column(:country_id, location_to_keep.id)
  print '.'
end
puts 'Done!'

# reload so all the associations are reset properly to no longer include
# the ones we've changed
location_to_destroy = WorldLocation.find('uk-delegation-to-the-oecd')
location_to_destroy.edition_world_locations.destroy_all
location_to_destroy.worldwide_organisation_world_locations.destroy_all
location_to_destroy.world_location_mainstream_links.destroy_all
UserWorldLocation.where(world_location_id: location_to_destroy.id).destroy_all
Contact.where(country_id: location_to_destroy.id).destroy_all
location_to_destroy.destroy

puts "Removed #{location_to_destroy.name}(#{location_to_destroy.slug})!"
