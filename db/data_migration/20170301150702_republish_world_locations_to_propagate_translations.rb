# We want to republish the following World Locations:
# Ukrain, Romainia, Thailand, Armenia, Japan
# because their translations seem not to have made their way into publishng api
#
ids = [7, 69, 113, 138, 154]

world_locations = WorldLocation.find(ids)

world_locations.each(&:save)
