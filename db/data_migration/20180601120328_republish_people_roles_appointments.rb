RoleAppointment.all.each do |role_appointment|
  Whitehall::PublishingApi.publish_async(role_appointment, 'republish', 'bulk_republishing')
end

Role.all.each do |role|
  Whitehall::PublishingApi.publish_async(role, 'republish', 'bulk_republishing')
end

Person.all.each do |person|
  Whitehall::PublishingApi.publish_async(person, 'republish', 'bulk_republishing')
end
