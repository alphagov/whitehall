ActiveRecord::Base.transaction do
  p "Changing role for Jeremy Wright"
  jeremy_wright = Person.where(forename: "Jeremy", surname: "Wright").first
  correct_role = Role.find_by(name: "Secretary of State for Digital, Culture, Media and Sport")
  incorrect_role = Role.find_by(name: "Secretary of State for Culture, Olympics, Media and Sport")

  correct_role_appointment = jeremy_wright.role_appointments.where(role_id: correct_role.id).first

  # Update consulations, publications etc. for old role appointments that must now go to the current role appointment
  incorrect_role_appointment = jeremy_wright.role_appointments.where(role_id: incorrect_role.id).first
  EditionRoleAppointment.where(role_appointment_id: incorrect_role_appointment.id).each do |edition_role_appointment|
    edition_role_appointment.update!(role_appointment_id: correct_role_appointment.id)
  end

  Edition.where(role_appointment_id: incorrect_role_appointment.id).each do |edition|
    edition.role_appointment_id = correct_role_appointment.id
    edition.save!(validate: false)
  end
  incorrect_role_appointment.delete
end
