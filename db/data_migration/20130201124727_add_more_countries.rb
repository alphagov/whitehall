require 'csv'

lines = created = 0
CSV.read(__FILE__.gsub(/\.rb/, '.csv'), headers: false, encoding: "UTF-8").each do |row|
  unless row[0].blank?
    lines += 1
    wl = WorldLocation.create(name: row[0], world_location_type: WorldLocationType::WorldLocation)
    created += 1 if wl.persisted?
  end
end

puts "Total rows: #{lines}, created countries: #{created}"
