uk = WorldLocation.where(iso2: 'GB').first

if uk
  uk.slug = 'united-kingdom'
  uk.save!
  puts "Added slug to United Kingdom"
end
