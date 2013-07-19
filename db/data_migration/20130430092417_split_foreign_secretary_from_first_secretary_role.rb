william_hague = Person.find_by_slug!('william-hague')
first_secretary_role = Role.find_by_slug!('first-secretary-of-state')
foreign_office = Organisation.find_by_slug('foreign-commonwealth-office')

puts "Step 1. Create new Secretary of State for Foreign and Commonwealth Affairs role"
foreign_secretary_role = MinisterialRole.create!( name: 'Secretary of State for Foreign and Commonwealth Affairs',
                                responsibilities: 'The Secretary of State has overall responsibility for the work of the Foreign & Commonwealth Office, with particular focus on policy strategy, honours, Whitehall liaison and cyber-security.',
                                organisations: [foreign_office],
                                supports_historical_accounts: true)
foreign_secretary_role.update_column(:slug, 'foreign-secretary')

puts "Step 2. Assign William Hague to the new role"
foreign_secretary_role_appointment = RoleAppointment.create!(person: william_hague, role: foreign_secretary_role, started_at: DateTime.new(2010, 5, 12))

puts "Step 3. Move associated Editions to the new role"
first_secretary_role.edition_ministerial_roles.update_all(ministerial_role_id: foreign_secretary_role.id)

puts "Step 4. Rename and update existing First Secretary of State role"
first_secretary_role.update_attributes(name: 'First Secretary of State', responsibilities: '')
