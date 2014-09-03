categories = MainstreamCategory.where(parent_tag: "citizenship/international-development")

categories.each do |category|
  old_path = Whitehall.url_maker.mainstream_category_path(category)
  puts "removing category: #{category.title}"
  guides = category.detailed_guides
  puts "\t removing association to category from #{guides.count} guides"
  guides.each do |guide|
    guide.update_attribute :primary_mainstream_category_id, nil
  end
  puts "\t destroying category: \t #{old_path} 💥🔫"
  category.destroy
end

puts "\nDon't forget to add the above redirects to router-data!"
