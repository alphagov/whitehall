require "data_hygiene/organisation_reslugger"

organisation = Organisation.find_by(slug: "companies-court")

DataHygiene::OrganisationReslugger.new(organisation, "companies-list").run!
