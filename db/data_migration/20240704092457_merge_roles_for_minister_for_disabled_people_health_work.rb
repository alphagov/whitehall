role_to_merge = Role.find_by(id: 2377)
role_to_keep = Role.find_by(id: 4494)

unless role_to_merge && role_to_keep
  puts "Roles not found - exiting."
  return
end

puts "merging #{role_to_merge.slug} into #{role_to_keep.slug}"

puts "Validating has no edition_role association..."
puts "count: ", EditionRole.where(role_id: role_to_merge.id).count

puts "Validating has no historical_account_roles association..."
puts "count: ", HistoricalAccountRole.where(role_id: role_to_merge.id).count

puts "Validating has no worldwide_organisation_roles association..."
puts "count: ", WorldwideOrganisationRole.where(role_id: role_to_merge.id).count

puts "checking role_appointments..."
affected_role_appointments = RoleAppointment.where(role_id: role_to_merge.id)
puts "role appointments affected: ", affected_role_appointments.count

affected_editions = (
  Edition.where(role_appointment_id: affected_role_appointments.pluck(:id)) +
  EditionRoleAppointment.where(role_appointment_id: affected_role_appointments.pluck(:id)).map(&:edition).compact
).uniq
puts "editions affected: ", affected_editions.count

puts "updating role appointment..."
affected_role_appointments.each do |role_appointment|
  print "."
  role_appointment.role_id = role_to_keep.id
  role_appointment.save!
end
puts "done"

puts "republishing affected editions..."
affected_editions.each do |edition|
  print "."
  Whitehall::PublishingApi.republish_document_async(edition.document, bulk: true)
end
puts "done"

puts "checking organisation_roles..."
affected_organisations = OrganisationRole.where(role_id: role_to_merge.id)
puts "organisations affected: ", affected_organisations.count

puts "republishing affected organisations..."
affected_organisations.each do |organisation|
  print "."
  organisation.save! # trigger callbacks
end
puts "done"
