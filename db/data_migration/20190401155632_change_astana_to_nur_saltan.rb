old_slug = "british-embassy-astana"
new_slug = "british-embassy-nur-sultan"

worldwide_organisation = WorldwideOrganisation.find_by!(slug: old_slug)
Whitehall::SearchIndex.delete(worldwide_organisation)
worldwide_organisation.update_attributes!(slug: new_slug)
