old_slug = "nhs-counter-fraud-agency"
new_slug = "nhs-counter-fraud-authority"

organisation = Organisation.find_by(slug: old_slug)

if organisation
  DataHygiene::OrganisationReslugger.new(organisation, new_slug).run!
end
