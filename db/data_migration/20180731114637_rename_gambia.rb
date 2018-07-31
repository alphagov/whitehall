gambia = WorldLocation.find_by(slug: "gambia")
gambia.update(slug: "the-gambia")
gambia.translation.update(name: "The Gambia")
