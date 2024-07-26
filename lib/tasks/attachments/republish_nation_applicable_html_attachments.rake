desc "Republish all documents with html attachments and national inapplicabilites"
task republish_nation_inapplicable_html_attachments: :environment do
  document_ids = Edition
    .publicly_visible
    .where(all_nation_applicability: false)
    .where(id: HtmlAttachment.where(attachable_type: "Edition").select(:attachable_id))
    .pluck(:document_id)

  puts "Enqueueing #{document_ids.count} documents with national inapplicabilites and html attachments"

  document_ids.each do |document_id|
    PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document_id, true)
  end

  puts "Finished enqueueing documents with national inapplicabilites and html attachments for republishing"
end
