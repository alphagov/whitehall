require "gds_api/router"
router_api = GdsApi::Router.new(Plek.find("router-api"))

duplicate_statistics_announcements = {
  "monthly-provisional-figures-on-deaths-registered-by-area-of-usual-residence-england-and-wales-july-2014" => "deaths-registered-by-area-of-usual-residence-in-england-and-wales-monthly-provisional-july-2014",
  "parents-country-of-birth-england-and-wales-2013" => "parents-country-of-birth-in-england-and-wales-2013",
}

duplicate_statistics_announcements.each do |dupe_slug, canonical_slug|
  duplicate = StatisticsAnnouncement.find(dupe_slug)
  canonical = StatisticsAnnouncement.find(canonical_slug)

  duplicate_path = Whitehall.url_maker.statistics_announcement_path(duplicate)
  canonical_path = Whitehall.url_maker.statistics_announcement_path(canonical)

  puts "registering redirect:\t #{duplicate_path} => #{canonical_path}"
  router_api.add_redirect_route(duplicate_path, "exact", canonical_path)
  puts "destroying duplicate:\t #{duplicate_path} 💥🔫"
  duplicate.destroy!
end

puts "\nDon't forget to add the above redirects to router-data!"
