old_slug = "south-georgia-and-south-sandwich-islands"
new_slug = "south-georgia-and-the-south-sandwich-islands"

world_location = WorldLocation.where(slug: old_slug)

Whitehall::SearchIndex.delete(world_location)

world_location.update_all(slug: new_slug)
