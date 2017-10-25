organisation = Organisation.find_by(slug: "digital-data-and-technology-professions")
organisation.name = "Digital, data and technology profession"
organisation.save!

new_slug = "digital-data-and-technology-profession"

DataHygiene::OrganisationReslugger.new(organisation, new_slug).run!
