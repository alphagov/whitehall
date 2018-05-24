roles_without_content_ids = Role.where(content_id: nil)
role_appointments_without_content_ids = RoleAppointment.where(content_id: nil)

roles_without_content_ids.each do |role|
  content_id = SecureRandom.uuid
  role.update(content_id: content_id)
end

role_appointments_without_content_ids.each do |role_appointment|
  content_id = SecureRandom.uuid
  role_appointment.update(content_id: content_id)
end
