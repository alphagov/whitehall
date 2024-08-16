# There were some deleted EditionableWorldwideOrganisation records hanging around to the database that were missed during the
# migration, so we'll clean those up first.
Edition.unscoped.where(type: "EditionableWorldwideOrganisation").update_all(type: "WorldwideOrganisation")

# Now remove any edition roles for deleted worldwide orgs. The edition roles should have been deleted when the worldwide
# organisation was deleted.
WorldwideOrganisation.unscoped.deleted.each { |wo| wo.edition_roles.clear }
