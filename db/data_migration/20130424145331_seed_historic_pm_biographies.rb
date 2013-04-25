def historic_biography_for(person, role_appointments)
  appointment_dates = role_appointments.collect { |a| "#{a.started_at.strftime("%Y")} to #{a.ended_at.strftime("%Y")}" }.to_sentence
  "#{person.name} served as Prime Minister between #{appointment_dates}. Read more about the life and achievements of #{person.name} in our [past Prime Ministers](/government/history/past-prime-ministers/#{person.slug}) section."
end

pm_role = Role.find_by_slug('prime-minister')
previous_pms = pm_role.previous_appointments.collect(&:person)

puts "Updating blank biographies for #{previous_pms.size} previous Prime Ministers"
previous_pms.each do |person|
  if person.biography.blank?
    puts "Setting default biography for #{person.name}"
    person.biography = historic_biography_for(person, person.role_appointments.for_role(pm_role))
    person.save!
  else
    puts "Warning: #{person.name} (#{person.id}) already has a biography! Not updating..."
  end
end
