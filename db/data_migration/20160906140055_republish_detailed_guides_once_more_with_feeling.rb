document_ids = Document
  .joins(:editions)
  .where(editions: { type: 'DetailedGuide' })
  .pluck(:id)
  .uniq

document_ids.each do |doc_id|
  PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", doc_id)
end
