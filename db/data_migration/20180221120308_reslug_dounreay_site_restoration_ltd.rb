require "data_hygiene/organisation_reslugger"

old_slug = "dounreay-site-restoration-ltd"
new_slug = "dounreay"

organisation = Organisation.find_by(slug: old_slug)

if organisation
  DataHygiene::OrganisationReslugger.new(organisation, new_slug).run!
end
