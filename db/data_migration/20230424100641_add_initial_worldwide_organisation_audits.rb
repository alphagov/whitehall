EVENT_TYPE = "initial".freeze

def log_message
  %(
    Number of WorldwideOrganisations: #{WorldwideOrganisation.count},
    Number of WorldwideOrganisation initial Versions: #{Version.where(item_type: WorldwideOrganisation.name, event: EVENT_TYPE).count}
  )
end

worldwide_organisation_ids = WorldwideOrganisation.pluck(:id)
initial_versions = []

worldwide_organisation_ids.each do |id|
  initial_versions << { event: EVENT_TYPE, item_type: WorldwideOrganisation.name, item_id: id }
end

puts "BEFORE: #{log_message}"
Version.insert_all!(initial_versions)
puts "AFTER: #{log_message}"
