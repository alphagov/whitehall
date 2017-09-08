document_ids = Consultation
  .find_each
  .map { |c| c.document_id if c.topical_events.present? }
  .compact
  .uniq

document_ids.each do |id|
  PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", id)
  print "."
end
