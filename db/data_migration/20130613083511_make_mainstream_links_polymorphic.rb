
organisation_mainstream_links = OrganisationMainstreamLink.includes(:mainstream_link)
puts "Converting #{organisation_mainstream_links.count} organisation mainstream links to be polymorphic"
organisation_mainstream_links.find_each do |oml|
  oml.mainstream_link.update_attributes!(linkable_type: 'Organisation', linkable_id: oml.organisation_id)
end

world_location_mainstream_links = WorldLocationMainstreamLink.includes(:mainstream_link)
puts "Converting #{world_location_mainstream_links.count} world location mainstream links to be polymorphic"
world_location_mainstream_links.find_each do |wlml|
  wlml.mainstream_link.update_attributes!(linkable_type: 'WorldLocation', linkable_id: wlml.world_location_id)
end

# Because the join model didn't have a :dependent option specified, "removed" mainstream links weren't getting deleted.
orphan_links = MainstreamLink.where(linkable_id: nil)
puts "Found #{orphan_links.count} orphaned mainstream links. Deleting..."
orphan_links.destroy_all
