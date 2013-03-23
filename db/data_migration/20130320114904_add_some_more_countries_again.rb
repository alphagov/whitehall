lines = 0
created = []
[
  ['American Samoa', 'american-samoa', 'AS'],
  ['Aruba', 'aruba', 'AW'],
  ['Bonaire/St Eustatius/Saba', 'bonaire-st-eustatius-saba', 'BQ'],
  ['British Indian Ocean Territory', 'british-indian-ocean-territory', 'IO'],
  ['Central African Republic', 'central-african-republic', 'CF'],
  ['Curaçao', 'curacao', 'CW'],
  ['French Guiana', 'french-guiana', 'GF'],
  ['French Polynesia', 'french-polynesia', 'PF'],
  ['Gabon', 'gabon', 'GA'],
  ['Gibraltar', 'gibraltar', 'GI'],
  ['Guadeloupe', 'guadeloupe', 'GP'],
  ['Martinique', 'martinique', 'MQ'],
  ['Mayotte', 'mayotte', 'YT'],
  ['Monaco', 'monaco', 'MC'],
  ['New Caledonia', 'new-caledonia', 'NC'],
  ['Réunion', 'reunion', 'RE'],
  ['San Marino', 'san-marino', 'SM'],
  ['South Georgia and the South Sandwich Islands', 'south-georgia-and-south-sandwich-islands', 'GS'],
  ['St Maarten', 'st-maarten', 'MF'],
  ['St Pierre & Miquelon', 'st-pierre-and-miquelon', 'PM'],
  ['Tonga', 'tonga', 'TO'],
  ['Wallis and Futuna', 'wallis-and-futuna', 'WF'],
  ['Western Sahara', 'western-sahara', 'EH']
].each do |country_details|
  lines += 1
  name, slug, iso2 = *country_details
  country = WorldLocation.new(name: name, iso2: iso2, title: "UK in #{name}", world_location_type: WorldLocationType::WorldLocation)
  country.save
  if country.persisted?
    country.update_column(:slug, slug)
    created << country
  end
end

puts "Total rows: #{lines}, created countries: #{created.size}: #{created.map{|wl| wl.name}.inspect}"
