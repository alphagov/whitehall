desc "Republish all documents containing $BrexitCTA in its body"
task republish_brexit_cta_documents: :environment do
  brexit_cta_document_ids = Edition.in_default_locale
                                   .includes(:document)
                                   .where("edition_translations.body LIKE ?", "%$BrexitCTA%")
                                   .pluck(:document_id)
                                   .uniq

  puts "Republishing #{brexit_cta_document_ids.count} documents..."
  republished_document_count = 0

  brexit_cta_document_ids.each do |document_id|
    PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
      "bulk_republishing",
      document_id,
    )

    republished_document_count += 1
    puts "#{republished_document_count}/#{brexit_cta_document_ids.count} documents republished"
  end
end
