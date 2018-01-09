require "data_hygiene/organisation_reslugger"

organisation = Organisation.find_by(slug: "department-for-communities-and-local-government")

DataHygiene::OrganisationReslugger.new(organisation, "ministry-of-housing-communities-and-local-government").run!
