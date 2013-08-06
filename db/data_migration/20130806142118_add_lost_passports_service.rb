if lost_and_stolen_passports = WorldwideService.where(name: 'Lost or Stolen Passports').first
  puts "Service #{lost_and_stolen_passports.name} already exists"
else
  lost_and_stolen_passports = WorldwideService.create!(name: 'Lost or Stolen Passports', service_type: WorldwideServiceType::AssistanceServices)
  puts "Service #{lost_and_stolen_passports.name} created"
end
