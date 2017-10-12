require "data_hygiene/organisation_reslugger"

organisation = Organisation.find_by(slug: "department-for-culture-media-sport")

DataHygiene::OrganisationReslugger.new(organisation, "department-for-digital-culture-media-sport").run!
