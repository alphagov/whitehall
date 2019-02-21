macedonia = WorldLocation.find_by(slug: "macedonia")
if macedonia
  macedonia.update!(slug: "north-macedonia")
  macedonia.translation.update!(name: "North Macedonia")
end
