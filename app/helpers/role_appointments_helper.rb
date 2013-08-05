module RoleAppointmentsHelper
  def array_of_links_to_role_appointments(role_appointments)
    role_appointments.map { |role_appointment|
      link_to role_appointment.person.name, role_appointment.person
    }
  end
end
