world_news_story_type_id = 4

editions = Edition
  .where(state: ["withdrawn", "published"])
  .where(news_article_type_id: world_news_story_type_id)

puts "Updating #{editions.count} editions"

editions.each do |edition|
  print "."
  SearchIndexAddWorker.perform_async_in_queue(
    "bulk_republishing",
    edition.class.name,
    edition.id
  )
  SearchIndexDeleteWorker.perform_async_in_queue(
    "bulk_republishing",
    "/government/world-location-news/#{edition.slug}",
    edition.rummager_index
  )
end
