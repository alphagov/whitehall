czech_republic = WorldLocation.find_by(slug: "czech-republic")
if czech_republic
  czech_republic.update!(slug: "czechia")
  czech_republic.translation.update!(name: "Czechia")
end
