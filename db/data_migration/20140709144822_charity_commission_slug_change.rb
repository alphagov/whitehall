require 'gds_api/router'

router = GdsApi::Router.new(Plek.find('router-api'))

old_slug = 'the-charity-commission-for-england-and-wales'
new_slug = 'charity-commission'

if (org = Organisation.find_by(slug: old_slug))
  puts "Changing org slug from #{old_slug} to #{new_slug}"

  # Remove document at old slug from search
  org.remove_from_search_index

  Organisation.transaction do
    org.slug = new_slug
    org.save!

    User.where(organisation_slug: old_slug).update_all(organisation_slug: new_slug)
  end

  # Index at new slug.
  org.update_in_search_index

  puts "Creating redirect for old org URL in router"
  router.add_redirect_route("/government/organisations/#{old_slug}",
                            "exact",
                            "/government/organisations/#{new_slug}")

  puts "Re-registering #{new_slug} published editions in search"
  org.editions.published.each(&:update_in_search_index)
else
  puts "No organisation found with slug #{old_slug}.  Skipping..."
end
