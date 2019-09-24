require "gds_api/router"

router = GdsApi::Router.new(Plek.find("router-api"))

not_found_slug = "/government/publications/vat-notice-7002-group-and-divisional-registration/vat-notice-7002-group-and-divisional-registration"
content_at_slug = "/government/publications/vat-notice-7002-group-and-divisional-registration/vat-notice-7002-group-and-divisional-registration--2"

puts "registering redirect #{not_found_slug} -> #{content_at_slug}"
router.add_redirect_route(not_found_slug, "exact", content_at_slug)
puts "done registering redirect"
