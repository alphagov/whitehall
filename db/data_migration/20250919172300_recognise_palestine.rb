palestine = WorldLocation.find_by(slug: "the-occupied-palestinian-territories")
raise "Could not find WorldLocation with slug the-occupied-palestinian-territories" if palestine.nil?

palestine.update!(slug: "palestine")
palestine.translation.update!(name: "Palestine")
