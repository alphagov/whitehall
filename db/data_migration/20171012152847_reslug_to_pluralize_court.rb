organisation = Organisation.find_by(slug: "the-business-and-property-court")
DataHygiene::OrganisationReslugger.new(organisation, "the-business-and-property-courts").run!
