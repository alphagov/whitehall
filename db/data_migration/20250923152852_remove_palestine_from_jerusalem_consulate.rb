jerusalem_worldwide_org = WorldwideOrganisation.where(title: "British Consulate General Jerusalem", state: "published").last
jerusalem_worldwide_org.world_locations = []
jerusalem_worldwide_org.save!(validate: false)
Whitehall::PublishingApi.publish(jerusalem_worldwide_org)
