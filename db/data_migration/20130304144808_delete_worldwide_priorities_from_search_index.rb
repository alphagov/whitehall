
puts "Removing Worldwide Priorities from the search index..."
WorldwidePriority.published.find_each do |priority|
  puts key = priority.search_index['link']
  Rummageable.delete(key, Whitehall.government_search_index_path)
end
puts "[Done]"
