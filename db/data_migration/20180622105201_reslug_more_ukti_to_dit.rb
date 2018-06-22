require "data_hygiene/organisation_reslugger"

ukti_worldwide_organisation_slugs = [
  ["uk-trade-investment-sri-lanka", "department-for-international-trade-sri-lanka"],
  ["ukti-turkmenistan", "department-for-international-trade-turkmenistan"]
]

ukti_worldwide_organisation_slugs.each do |slug|
  organisation = WorldwideOrganisation.find_by(slug: slug[0])
  DataHygiene::OrganisationReslugger.new(organisation, slug[1]).run!
end
