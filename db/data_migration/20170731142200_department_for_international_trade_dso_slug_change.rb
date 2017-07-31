require 'data_hygiene/organisation_reslugger'

old_slug = "uk-trade-and-investment-defence-and-security-organisation"
new_slug = "department-for-international-trade-defence-and-security-organisation"

organisation = Organisation.find_by!(slug: old_slug)
DataHygiene::OrganisationReslugger.new(organisation, new_slug).run!
