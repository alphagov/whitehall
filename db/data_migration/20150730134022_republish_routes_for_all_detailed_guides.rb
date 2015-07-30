require 'plek'
require 'gds_api/router'

router_api = GdsApi::Router.new(Plek.find('router-api'))

scope = Document.distinct.
  joins(:editions).
  where(document_type: "DetailedGuide",
    editions: {state: Edition::POST_PUBLICATION_STATES})

count = scope.count

scope.each_with_index do |guide, i|
  if guide.ever_published_editions.any?
    slug = guide.slug.sub(%r{^deleted-}, '')
    puts "Adding route #{i+1}/#{count} for /#{slug}"
    router_api.add_route("/#{slug}", "exact", "whitehall-frontend")
  end
end

router_api.commit_routes
