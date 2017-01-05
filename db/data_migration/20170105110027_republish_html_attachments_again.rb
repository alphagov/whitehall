# HtmlAttachments are now republished when their parent document is republished.
# This encapsulates all the logic of decided what states need to go where etc.

document_ids = Edition.joins(
  "INNER JOIN attachments ON attachable_id = editions.id
   AND attachments.type = 'HtmlAttachment'"
).pluck(:document_id).uniq

puts "Republishing #{document_ids.count} documents"

document_ids.each do |document_id|
  print "."
  PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document_id)
end
