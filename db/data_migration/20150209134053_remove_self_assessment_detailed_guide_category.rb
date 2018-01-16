require 'gds_api/router'
router_api = GdsApi::Router.new(Plek.current.find('router-api'))

REDIRECT_TO = "/government/organisations/hm-revenue-customs".freeze

categories = MainstreamCategory.where(parent_tag: "tax/self-assessment")

categories.each do |category|
  old_path = Whitehall.url_maker.mainstream_category_path(category)
  puts "removing category: #{category.title}"
  guides = category.detailed_guides

  puts "\t registering redirect: #{old_path} => #{REDIRECT_TO}"
  router_api.add_redirect_route(old_path, 'exact', REDIRECT_TO)

  puts "\t removing association to category from #{guides.count} guides"
  guides.each { |guide| guide.remove_mainstream_category!(category) }

  puts "\t destroying category: \t #{old_path}"
  category.destroy
end

puts "committing redirects"
router_api.commit_routes

puts "\nDon't forget to add the above redirects to router-data!"
