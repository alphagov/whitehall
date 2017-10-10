require "data_hygiene/organisation_reslugger"

organisation = Organisation.find_by(slug: "bankruptcy-court")

DataHygiene::OrganisationReslugger.new(organisation, "insolvency-list").run!
