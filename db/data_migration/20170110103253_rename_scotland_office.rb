scotland_office = Organisation.find_by(slug: "scotland-office")

# Rename the organisation
new_name = "UK Government Scotland"
scotland_office.update_attributes!(name: new_name)

# Modify the address accordingly
new_slug = "uk-government-scotland"
DataHygiene::OrganisationReslugger.new(scotland_office, new_slug).run!
