ActiveRecord::Base.transaction do
  sarah_albon = Person.find_by(forename: "Sarah", surname: "Albon")
  correct_role = Role.find_by(name: "Chief Executive Officer, The Insolvency Service ")
  incorrect_role = Role.find_by(name: "Interim Chief Executive Officer, The Insolvency Service ")

  correct_role_appointment = sarah_albon.role_appointments.find_by(role_id: correct_role.id)
  incorrect_role_appointment = sarah_albon.role_appointments.find_by(role_id: incorrect_role.id)

  # Update consulations, publications etc. for old role appointments that must now go to the current role appointment
  Edition.where(role_appointment_id: incorrect_role_appointment.id).each do |edition|
    edition.role_appointment_id = correct_role_appointment.id
    edition.save!(validate: false)
  end

  incorrect_role_appointment.delete
end
