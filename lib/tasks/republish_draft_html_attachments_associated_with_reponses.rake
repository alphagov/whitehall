desc "Republish all documents with draft html attachments whose parent is a `Response`"
task republish_draft_html_attachments_associated_with_responses: :environment do
  consultation_ids = HtmlAttachment
                      .includes(:attachable)
                      .where(attachable_type: "Response")
                      .map { |html_attachment| html_attachment.attachable.edition_id }

  document_ids = Consultation
                  .in_pre_publication_state
                  .where(id: consultation_ids)
                  .pluck(:document_id)

  puts "Enqueueing #{document_ids.count} documents with `Responses` for republishing"

  document_ids.each do |document_id|
    PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document_id, true)
  end

  puts "Finished enqueueing documents with `Responses` for republishing"
end
