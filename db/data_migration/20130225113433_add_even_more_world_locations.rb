lines = 0
created = []
[
  ['St Helena, Ascension and Tristan da Cunha', WorldLocationType::OverseasTerritory, 'sh'], # territory, ISO: SH, SHN, 654
  ['St Lucia', WorldLocationType::Country, 'lc'], # country, ISO: LC, LCA, 662
  ['Kyrgyzstan', WorldLocationType::Country, 'kg'], # Country, ISO: KG, KGZ, 417
  ['Pitcairn Island', WorldLocationType::OverseasTerritory, 'pn'] # territory, ISO: PN, PCN, 612
].each do |new_world_location|
  lines += 1
  name, type, iso2 = *new_world_location
  wl = WorldLocation.new(name: name, world_location_type: type)
  wl.iso2 = iso2 if [WorldLocationType::Country, WorldLocationType::OverseasTerritory].include? type
  wl.title =
    if [WorldLocationType::Country, WorldLocationType::OverseasTerritory].include? type
      'UK in '+name
    else
      name
    end
  wl.save
  created << wl if wl.persisted?
end

puts "Total rows: #{lines}, created world locations: #{created.size}: #{created.map{|wl| wl.name}.inspect}"
