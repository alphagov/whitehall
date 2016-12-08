chief_inspector = WorldwideOrganisation.find_by(slug: "chief-inspector-of-the-uk-border-agency")

new_slug = "independent-chief-inspector-of-borders-and-immigration"
DataHygiene::OrganisationReslugger.new(chief_inspector, new_slug).run!
