namespace :wlna do
  task :migrate_to_news_article, [:start_document_id, :end_document_id] => :environment do |_t, args|
    start_id = args[:start_document_id]
    end_id = args[:end_document_id]
    raise "start_document_id and end_document_id must be supplied" unless start_id && end_id

    documents = Document.where(id: start_id..end_id)
      .where(document_type: "WorldLocationNewsArticle")

    puts "Migrating #{documents.count} WLNA -> NewsArticle"
    documents.each do |wlna_document|
      begin
        #setting sluggable_string causes #should_generate_new_friendly_id?
        #to return true. This will regenerate the slug and
        #disambiguate if there is already a news article with the slug
        wlna_document.sluggable_string = wlna_document.slug
        wlna_document.update_attributes(
          document_type: "NewsArticle",
        )
      rescue ActiveRecord::RecordNotUnique
        puts "NotUnique: #{wlna_document.id}"
      end

      editions = editions_including_deleted(wlna_document.id)

      update_db_records_to_news_article(editions)
      update_unpublishings(editions)
      update_rummager(editions)

      PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", wlna_document.id)

      print "."
    end

    unless documents.empty?
      puts "First document id #{documents.first.id}"
      puts "Last document id #{documents.last.id}"
    end
  end
end

def update_db_records_to_news_article(editions)
  editions.update_all(
    type: "NewsArticle",
    news_article_type_id: NewsArticleType::WorldNewsStory.id
  )
end

def update_unpublishings(editions)
  edition_ids = editions.pluck(:id)
  unpublishings = Unpublishing.where(edition_id: edition_ids)
  unpublishings.update_all(document_type: "NewsArticle")
end

def update_rummager(editions)
  editions.each(&:save)
end

def editions_including_deleted(document_id)
  Edition.unscoped.where(document_id: document_id)
end
