lines = 0
created = []
[
  ['Bermuda', WorldLocationType::WorldLocation, 'bm'],
  ['Burundi', WorldLocationType::WorldLocation, 'bi'],
  ['El Salvador', WorldLocationType::WorldLocation, 'sv'],
  ['Falkland Islands', WorldLocationType::WorldLocation, 'fk'],
  ['Guinea', WorldLocationType::WorldLocation, 'gn'],
  ['UK Mission to the United Nations, New York', WorldLocationType::InternationalDelegation],
  ['UK Delegation to Council of Europe', WorldLocationType::InternationalDelegation],
  ['The UK Permanent Delegation to the OECD (Organisation for Economic Co-operation and Development)', WorldLocationType::InternationalDelegation],
  ['UK Joint Delegation to NATO (North Atlantic Treaty Organization)', WorldLocationType::InternationalDelegation],
  ['UK Representation to the EU (European Union)', WorldLocationType::InternationalDelegation],
  ['UK Mission Geneva', WorldLocationType::InternationalDelegation],
  ['UK Delegation to OSCE, Vienna (Organization for Security and Co-operation in Europe)', WorldLocationType::InternationalDelegation],
  ['United Kingdom Mission to United Nations in Vienna', WorldLocationType::InternationalDelegation]
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

puts "Total rows: #{lines}, created countries: #{created.size}: #{created.map{|wl| wl.name}.inspect}"
