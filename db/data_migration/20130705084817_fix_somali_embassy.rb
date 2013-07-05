# WorldwideOrganisations have an implicit office, which was already
# updated in 20130701154722_update_fco_embassy.rb. This cleans up the
# actual org we wanted to update.
wwo = WorldwideOrganisation.find_by_slug "british-office-for-somalia"
wwo.update_column(:slug, "british-embassy-mogadishu")
