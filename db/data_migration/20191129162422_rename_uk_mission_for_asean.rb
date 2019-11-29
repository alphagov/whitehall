asean_mission = WorldLocation.find_by(slug: "uk-mission-for-asean")
if asean_mission
  asean_mission.update!(slug: "uk-mission-to-asean")
  asean_mission.translation.update!(name: "UK Mission to ASEAN")
  asean_mission.translation.update!(title: "UK Mission to ASEAN")
end
