nauru = WorldLocation.find_by(slug: "nauru")
if nauru
  nauru.update!(slug: "naoero")
  nauru.translation.update!(name: "Naoero")
end
