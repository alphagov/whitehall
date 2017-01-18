scotland_office = Organisation.find_by(slug: "uk-government-scotland")

# Rename the organisation
new_name = "Scotland Office"
scotland_office.update_attributes!(name: new_name)

# Modify the address accordingly
new_slug = "scotland-office"
DataHygiene::OrganisationReslugger.new(scotland_office, new_slug).run!
