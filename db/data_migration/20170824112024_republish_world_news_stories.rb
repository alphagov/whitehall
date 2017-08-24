# Republishes documents for world news stories.

document_ids = NewsArticle
  .where(news_article_type_id: NewsArticleType::WorldNewsStory.id)
  .pluck(:document_id)
  .uniq

document_ids.each do |id|
  PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", id)
  print "."
end

puts
