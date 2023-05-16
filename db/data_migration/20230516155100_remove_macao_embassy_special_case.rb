location = WorldLocation.find_by!(slug: "macao")
organisation = WorldwideOrganisation.find_by!(slug: "british-embassy-macao")
organisation.world_locations -= [location]

organisation = WorldwideOrganisation.find_by!(slug: "british-consulate-general-hong-kong")
organisation.world_locations += [location] unless organisation.world_locations.include?(location)

location.reload

embassy = Embassy.new(location)
unless embassy.organisations_with_embassy_offices == [organisation]
  msg = <<~END_MESSAGE
    Expected #{location} to have a single embassy organisation of #{organisation.slug}
    But actually contains #{embassy.organisations_with_embassy_offices.map(&:slug)}
  END_MESSAGE
  raise msg
end
