role_to_merge = Role.find_by(id: 2377)
role_to_keep = Role.find_by(id: 4494)

unless role_to_merge && role_to_keep
  puts "Roles not found - exiting."
  return
end

puts "checking organisation_roles..."
affected_organisation_role = OrganisationRole.where(role_id: role_to_merge.id)
puts "organisations affected: ", affected_organisation_role.count

puts "republishing affected organisations..."
affected_organisation_role.each do |organisation_role|
  print "."
  organisation_role.role_id = role_to_keep.id
  organisation_role.save! # trigger callbacks
end
puts "done"
