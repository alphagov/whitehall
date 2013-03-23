lines = 0
created = []
[
  ['St Helena, Ascension and Tristan da Cunha', WorldLocationType::WorldLocation, 'sh'], # territory, ISO: SH, SHN, 654
  ['St Lucia', WorldLocationType::WorldLocation, 'lc'], # country, ISO: LC, LCA, 662
  ['Kyrgyzstan', WorldLocationType::WorldLocation, 'kg'], # Country, ISO: KG, KGZ, 417
  ['Pitcairn Island', WorldLocationType::WorldLocation, 'pn'] # territory, ISO: PN, PCN, 612
].each do |new_world_location|
  lines += 1
  name, type, iso2 = *new_world_location
  wl = WorldLocation.new(name: name, world_location_type: type)
  wl.iso2 = iso2 if [WorldLocationType::WorldLocation].include? type
  wl.title =
    if [WorldLocationType::WorldLocation].include? type
      'UK in '+name
    else
      name
    end
  wl.save
  created << wl if wl.persisted?
end

puts "Total rows: #{lines}, created world locations: #{created.size}: #{created.map{|wl| wl.name}.inspect}"
