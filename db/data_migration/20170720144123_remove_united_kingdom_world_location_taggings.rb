# Remove all instances where editions have been tagged to "United Kingdom" as
# a WorldLocation, before removing the WorldLocation itself.

UK_WORLD_LOCATION_ID = 202

EditionWorldLocation.where(world_location_id: UK_WORLD_LOCATION_ID).destroy

WorldLocation.find(UK_WORLD_LOCATION_ID).destroy
