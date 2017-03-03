require 'data_hygiene/organisation_reslugger'

organisation = Organisation.find_by(slug: "her-majestys-magistrates-courts-servuce-inspectorate")

DataHygiene::OrganisationReslugger.new(organisation, "her-majestys-magistrates-courts-service-inspectorate").run!
