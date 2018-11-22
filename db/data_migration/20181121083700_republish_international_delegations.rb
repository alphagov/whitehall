DataHygiene::PublishingApiRepublisher
  .new(WorldLocation.where(world_location_type_id: WorldLocationType::InternationalDelegation.id))
  .perform
