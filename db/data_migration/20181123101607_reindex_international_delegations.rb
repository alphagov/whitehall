# Reindexes all international delegations with new description
#
delegations = WorldLocation.where(world_location_type_id: WorldLocationType::InternationalDelegation.id)
delegations.each { |delegation| Whitehall::SearchIndex.add(delegation) }
