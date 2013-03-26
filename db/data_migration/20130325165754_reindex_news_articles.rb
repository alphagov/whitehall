# Re-index all news articles to pick up new, slightly different
# search_format_types that are based on key, not singular_name
puts "Reindexing #{NewsArticle.published.count} published news articles: "
i = 0 # find_each isn't a real enumerator :(
NewsArticle.published.find_each do |na|
  na.remove_from_search_index
  na.update_in_search_index
  print '.' if ((i % 100) == 0)
  i += 1 
end
puts " Done!"