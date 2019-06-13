burma = WorldLocation.find_by(slug: "burma")
if burma
  burma.update!(slug: "myanmar")
  burma.translation.update!(name: "Myanmar")
end