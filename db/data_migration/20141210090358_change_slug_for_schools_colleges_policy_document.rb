require 'gds_api/router'
router = GdsApi::Router.new(Plek.find('router-api'))

slug = 'making-schools-and-colleges-more-accountable-and-giving-them-more-control-over-their-budget'
new_slug = 'making-schools-and-colleges-more-accountable-and-funding-them-fairly'

# load the policy and the supporting pages
policy = Policy.published_as(slug)
supporting_pages = policy.published_supporting_pages

# remove the old versions from the search index
Whitehall::SearchIndex.for(:government).delete(policy)

supporting_pages.each do |supporting_page|
  Whitehall::SearchIndex.for(:government).delete(supporting_page)
end

# change the slug on the parent document
policy.document.slug = new_slug
policy.document.save!

# re-index the new versions
Whitehall::SearchIndex.for(:government).add(policy)

supporting_pages.each do |supporting_page|
  Whitehall::SearchIndex.for(:government).add(supporting_page)
end

# set the redirect
router.add_redirect_route("/government/policy/#{slug}",
                          'exact',
                          "/government/policy/#{new_slug}")
router.commit_routes
