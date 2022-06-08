desc "Republish all documents with html attachments which are historically political"
task republish_historically_political_html_attachments: :environment do
  government_start_date = Government.current.start_date

  document_ids = Edition
    .publicly_visible
    .where(id: HtmlAttachment.where("attachable_type = 'Edition' AND political = true AND first_published_at < ?", government_start_date).select(:attachable_id))
    .pluck(:document_id)

  puts "Enqueueing #{document_ids.count} documents with historically political html attachments"

  document_ids.each do |document_id|
    PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document_id, true)
  end

  puts "Finished enqueueing documents with historically political HtmlAttachments for republishing"
end
