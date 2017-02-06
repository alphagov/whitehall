madrid_office = WorldwideOffice.find_by(
  slug: 'british-consulate-general-madrid--2'
)
organisation = madrid_office.worldwide_organisation

if organisation.slug != 'british-consulate-general-madrid'
  raise "Unexpected organisation #{organisation.name} for Madrid Office"
end

new_slug = 'british-consulate-general-madrid'
madrid_office.update_attributes!(slug: new_slug)
