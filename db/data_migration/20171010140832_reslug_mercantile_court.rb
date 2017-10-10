require "data_hygiene/organisation_reslugger"

organisation = Organisation.find_by(slug: "mercantile-court")

DataHygiene::OrganisationReslugger.new(organisation, "commercial-circuit-court").run!
