EditionMinisterialRole.all.each do |edition_ministerial_role|
  unless (role = edition_ministerial_role.ministerial_role)
    puts "Could not find role ##{edition_ministerial_role.ministerial_role_id} for edition_ministerial_role ##{edition_ministerial_role.id}"
    next
  end

  unless (edition = edition_ministerial_role.edition)
    puts "Could not find edition ##{edition_ministerial_role.edition_id} for edition_ministerial_role ##{edition_ministerial_role.id}"
    next
  end

  unless (role_appointment = RoleAppointment.for_role(role).where("started_at <= ?", edition.first_public_at).order(started_at: :desc).first)
    puts "Could not find role appointment for ministerial role ##{edition_ministerial_role.ministerial_role_id} for edition_ministerial_role ##{edition_ministerial_role.id}"
    next
  end

  if EditionRoleAppointment.exists?(edition_id: edition.id, role_appointment_id: role_appointment.id)
    puts "Link already exists from edition ##{edition.id} to role appointment ##{role_appointment.id}"
  else
    puts "Linking edition ##{edition.id} to role appointment ##{role_appointment.id}"
    EditionRoleAppointment.create!(edition_id: edition.id, role_appointment_id: role_appointment.id)
  end
end
