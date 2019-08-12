orgs = Organisation.where(organisation_type_key: :tribunal_ndpb)

orgs.each do |org|
  puts "Changing #{org.name} old org type #{org.organisation_type_key}"

  org.update_attributes!(organisation_type_key: :tribunal)

  puts "#{org.name} new org type: #{org.organisation_type_key}"
end
