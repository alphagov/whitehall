worldwide_organisation = WorldwideOrganisation.find_by(slug: "british-indian-ocean-territory")
cip = worldwide_organisation.corporate_information_pages.find(&:force_published?)

Whitehall.edition_services.deleter(cip).perform!
