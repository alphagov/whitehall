ActiveRecord::Base.transaction do
  p "Changing role for Matthew Hancock"
  matt_hancock = Person.where(forename: "Matt", surname: "Hancock").first
  correct_role = Role.find_by(name: "Secretary of State for Digital, Culture, Media and Sport")
  incorrect_role_one = Role.find_by(name: "Secretary of State for Culture, Media and Sport")
  incorrect_role_two = Role.find_by(name: "Secretary of State for Culture, Olympics, Media and Sport")

  correct_role_appointment = matt_hancock.role_appointments.where(role_id: correct_role.id).first

  # Update consulations, publications etc. for old role appointments that must now go to the current role appointment
  [incorrect_role_one, incorrect_role_two].each do |role|
    incorrect_role_appointment = matt_hancock.role_appointments.where(role_id: role.id).first
    EditionRoleAppointment.where(role_appointment_id: incorrect_role_appointment).each do |edition_role_appointment|
      edition_role_appointment.update!(role_appointment_id: correct_role_appointment.id)
    end
    Edition.where(role_appointment_id: incorrect_role_appointment.id).each do |edition|
      edition.role_appointment_id = correct_role_appointment.id
      edition.save!(validate: false)
    end
    incorrect_role_appointment.delete
  end
end

[ { forename: "Karen", surname: "Bradley" },
  { forename: "John", surname: "Whittingdale" },
  { forename: "Sajid", surname: "Javid" },
  { forename: "Maria", surname: "Miller" } ].each do |person_details|
  ActiveRecord::Base.transaction do
    p "Changing role for #{person_details[:forename]} #{person_details[:surname]}"
    person = Person.where(person_details).first
    correct_role = Role.find_by(name: "Secretary of State for Culture, Media and Sport")
    incorrect_role = Role.find_by(name: "Secretary of State for Culture, Olympics, Media and Sport")

    correct_role_appointment = person.role_appointments.where(role_id: correct_role.id).first
    incorrect_role_appointment = person.role_appointments.where(role_id: incorrect_role.id).first

    # Update consulations, publications etc. for old role appointments that must now go to the current role appointment
    EditionRoleAppointment.where(role_appointment_id: incorrect_role_appointment.id).each do |edition_role_appointment|
      edition_role_appointment.update!(role_appointment_id: correct_role_appointment.id)
    end
    Edition.where(role_appointment_id: incorrect_role_appointment.id).each do |edition|
      edition.role_appointment_id = correct_role_appointment.id
      edition.save!(validate: false)
    end
    incorrect_role_appointment.delete
  end
end
