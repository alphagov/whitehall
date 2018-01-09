require "data_hygiene/organisation_reslugger"

organisation = Organisation.find_by(slug: "department-of-health")

DataHygiene::OrganisationReslugger.new(organisation, "department-of-health-and-social-care").run!
