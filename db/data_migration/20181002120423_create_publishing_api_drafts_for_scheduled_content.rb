Document.where(
  id: Edition.where(state: :scheduled).select(:document_id)
).pluck(:id).each do |document_id|
  puts "Enqueuing document #{document_id}"
  PublishingApiDocumentRepublishingWorker.perform_async(document_id)
end
