Person.all.find_each do |person|
  current_role_appointments = person.current_role_appointments
  current_role_appointments.each do |role_appointment|
    role_appointment.publish_to_publishing_api
    role = role_appointment.role
    role.publish_to_publishing_api
  end
end
