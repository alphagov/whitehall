require 'csv'

namespace :news_article do
  desc "Remove inaccessible alt text"
  task remove_inaccessible_alt_text: :environment do

    ids = CSV.read(Rails.root.join('lib', 'tasks', 'newsarticle_alt_text_ids.csv'), :headers=>true)
    image_ids = ids['image_id']
    article_ids = ids['article_id']

    puts "Updating #{image_ids.count} images alt_text to nil"
    Image.where(id: image_ids).update_all(alt_text: nil)
    puts "Finished updating"

    document_ids = NewsArticle.where(id: article_ids).pluck(:document_id).uniq
    puts "Bulk republishing #{document_ids.count} NewsArticles"
    document_ids.each do |id|
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", id, true)
    end

    puts "Finished republishing"
  end
end
