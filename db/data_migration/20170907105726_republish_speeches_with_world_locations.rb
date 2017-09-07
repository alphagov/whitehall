document_ids = Speech.find_each.map { |s| s.document_id if s.world_locations.present? }.compact

document_ids.each do |id|
  PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", id)
  print "."
end
