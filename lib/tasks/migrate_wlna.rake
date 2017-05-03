namespace :wlna do
  desc "
    Convert a WorldLocationNewsArticle to a NewsArticle
    Usage
      rake 'wlna:convert_to_news[<document_id>]
  "
  task :convert_to_news, [:document_id] => :environment do |_, args|
    document = Document.find(args.document_id)
    raise "Document isn't a WLNA" unless document.document_type == "WorldLocationNewsArticle"

    editions = document.editions
    Document.transaction do
      document.update_column(:document_type, "NewsArticle")
      editions.each do |edition|
        edition.update_columns(
          type: "NewsArticle",
          news_article_type_id: NewsArticleType::NewsStory.id,
        )
      end
    end

    PublishingApiDocumentRepublishingWorker.perform_async(document.id)
  end
end
