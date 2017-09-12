world_location = WorldLocation.where(slug: "niger").first
world_location.active = true
world_location.save!
