module RoleAppointmentsHelper
  def list_of_links_to_role_appointments(role_appointments)
    role_appointments.map { |role_appointment| link_to role_appointment.person.name, role_appointment.person, class: "person" }.to_sentence.html_safe
  end

  def year_range_for(role_appointments)
    if role_appointments.any?
      "#{role_appointments.first.ended_at.year} &ndash; #{role_appointments.last.started_at.year}".html_safe
    end
  end
end
