require 'gds_api/router'
router_api = GdsApi::Router.new(Plek.find('router-api'))

REDIRECT_TO = "/international-development-funding".freeze

categories = MainstreamCategory.where(parent_tag: "citizenship/international-development")

categories.each do |category|
  old_path = Whitehall.url_maker.mainstream_category_path(category)
  puts "removing category: #{category.title}"
  guides = category.detailed_guides

  puts "\t registering redirect: #{old_path} => #{REDIRECT_TO}"
  router_api.add_redirect_route(old_path, 'exact', REDIRECT_TO)

  puts "\t removing association to category from #{guides.count} guides"
  guides.each do |guide|
    if guide.primary_mainstream_category_id == category.id
      guide.update_attribute :primary_mainstream_category_id, nil
    elsif guide.other_mainstream_category_ids.include? category.id
      new_ids = guide.other_mainstream_category_ids.reject { |id| id == category.id }
      guide.update_attribute :other_mainstream_category_ids, new_ids
    end
  end

  puts "\t destroying category: \t #{old_path} 💥🔫"
  category.destroy
end

puts "committing redirects"
router_api.commit_routes

puts "\nDon't forget to add the above redirects to router-data!"
