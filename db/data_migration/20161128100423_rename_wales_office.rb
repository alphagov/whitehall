wales_office = Organisation.find_by(slug: "wales-office")

# Rename the organisation
new_name = "Office of the Secretary of State for Wales"
wales_office.update_attributes!(name: new_name)

# Modify the address accordingly
new_slug = "office-of-the-secretary-of-state-for-wales"
DataHygiene::OrganisationReslugger.new(wales_office, new_slug).run!
