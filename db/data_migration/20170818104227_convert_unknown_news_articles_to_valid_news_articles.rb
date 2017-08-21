begin
  unknown_news_articles = NewsArticle.by_subtype(NewsArticleType::Unknown)
  published_unknown_news_articles = unknown_news_articles.published
  document_ids = unknown_news_articles.map { |n| n.document_id }.uniq
  press_releases = unknown_news_articles.includes(:document).select { |n| n.slug.include?("press-release") }
  news_stories = unknown_news_articles - press_releases

  # Update NewsArticles in Whitehall
  press_releases.update_all(news_article_type_id: NewsArticleType::PressRelease.id)
  press_releases.where(minor_change: false, change_note: nil).update_all(change_note: "This news article was converted to a press release")

  news_stories.update_all(news_article_type_id: NewsArticleType::NewsStory.id)
  news_stories.where(minor_change: false, change_note: nil).update_all(change_note: "This news article was converted to a news story")

  # Republish updated NewsArticles to PublishingAPI
  document_ids.each do |id|
    PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", id)
    print "."
  end

  # Update content in Rummager
  published_unknown_news_articles.each do |edition|
    SearchIndexDeleteWorker.perform_async_in_queue(
      "bulk_republishing",
      "/government/news/#{edition.slug}",
      edition.rummager_index
    )
    SearchIndexAddWorker.perform_async_in_queue(
      "bulk_republishing",
      edition.class.name,
      edition.id
    )
  end
rescue NameError => e
  puts "Can't apply data migration: #{e.message}"
end
