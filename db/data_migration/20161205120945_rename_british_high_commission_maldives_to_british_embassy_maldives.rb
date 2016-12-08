british_embassy_maldives = WorldwideOrganisation.find_by(slug: "british-high-commission-maldives")

new_slug = "british-embassy-maldives"
DataHygiene::OrganisationReslugger.new(british_embassy_maldives, new_slug).run!
