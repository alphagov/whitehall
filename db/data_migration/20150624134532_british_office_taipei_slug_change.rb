require "data_hygiene/organisation_reslugger"

organisation = WorldwideOrganisation.find_by(slug: "british-trade-cultural-office-taiwan")

DataHygiene::OrganisationReslugger.new(organisation, "british-office-taipei").run!
