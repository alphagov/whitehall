module RoleAppointmentsHelper
  def array_of_links_to_role_appointments(role_appointments)
    role_appointments.map do |role_appointment|
      link_to role_appointment.person.name, role_appointment.person, class: "role-appointment-link"
    end
  end
end
