desc "Republish all documents containing $BrexitCTA in its body"
task republish_brexit_cta_documents: :environment do
  brexit_cta_document_ids = Edition.in_default_locale
                                   .includes(:document)
                                   .where("edition_translations.body LIKE ?", "%$BrexitCTA%")
                                   .pluck(:document_id)
                                   .uniq

  puts "Republishing #{brexit_cta_document_ids.count} documents..."

  brexit_cta_document_ids.each_with_index do |document_id, republished_document_count|
    PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
      "bulk_republishing",
      document_id,
    )
    puts "#{republished_document_count}/#{brexit_cta_document_ids.count} documents republished"
  end
end
