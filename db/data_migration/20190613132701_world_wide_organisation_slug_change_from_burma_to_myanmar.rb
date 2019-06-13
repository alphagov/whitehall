require 'data_hygiene/organisation_reslugger'

 dfid = WorldwideOrganisation.find_by(slug: "dfid-burma")
 dit = WorldwideOrganisation.find_by(slug: "department-for-international-trade-burma")

 DataHygiene::OrganisationReslugger.new(dfid, "dfid-myanmar").run!
 DataHygiene::OrganisationReslugger.new(dit, "department-for-international-trade-myanmar").run!