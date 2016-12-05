document_ids = Edition
  .where(id: HtmlAttachment.pluck(:attachable_id))
  .where(state: %w(published draft withdrawn submitted scheduled))
  .pluck(:document_id)
  .uniq

document_ids.each do |document_id|
  print "."
  PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
    "bulk_republishing",
    document_id
  )
end
