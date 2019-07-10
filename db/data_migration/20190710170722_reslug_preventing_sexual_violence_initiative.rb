require 'data_hygiene/organisation_reslugger'

organisation = Organisation.find_by(slug: "preventing-sexual-violence-initiative")

DataHygiene::OrganisationReslugger.new(organisation, "preventing-sexual-violence-in-conflict-initiative").run!
