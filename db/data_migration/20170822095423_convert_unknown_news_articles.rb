begin
  unknown_news_articles = NewsArticle.by_subtype(NewsArticleType::Unknown)
  document_ids = unknown_news_articles.map { |n| n.document_id }.uniq
  published_edition_ids = unknown_news_articles.published.map(&:id)

  # We want to return ActiveRecord relations here, so that `update_all` works
  press_releases = unknown_news_articles.joins(:document).where("documents.slug REGEXP ?", 'press-release')
  news_story_ids = (unknown_news_articles - press_releases).map(&:id)
  news_stories = NewsArticle.where(id: news_story_ids)

  # Update NewsArticles in Whitehall
  press_releases.update_all(news_article_type_id: NewsArticleType::PressRelease.id)
  press_releases.where(minor_change: false, change_note: nil).update_all(change_note: "This news article was converted to a press release")

  news_stories.update_all(news_article_type_id: NewsArticleType::NewsStory.id)
  news_stories.where(minor_change: false, change_note: nil).update_all(change_note: "This news article was converted to a news story")

  # Republish updated NewsArticles to PublishingAPI
  puts "Updating PublishingAPI"
  document_ids.each do |id|
    PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", id)
    print "."
  end

  # Update content in Rummager
  puts "Updating Rummager"
  published_editions = NewsArticle.find(published_edition_ids)
  published_editions.each do |edition|
    SearchIndexAddWorker.perform_async_in_queue(
      "bulk_republishing",
      edition.class.name,
      edition.id
    )
    print "."
  end
rescue NameError => e
  puts "Can't apply data migration: #{e.message}"
end
