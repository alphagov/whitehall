latest_publication_document_ids = Document.where(
  id: Publication.where(state: %w(draft published withdrawn)).pluck(:id)
)
  .order(id: :desc)
  .limit(10000)
  .pluck(:id)

latest_publication_document_ids.each do |document_id|
  print "."
  PublishingApiDocumentRepublishingWorker.perform_async(document_id)
end

puts "\n" * 10
puts "*" * 50
puts "Last document republished #{latest_publication_document_ids.last}"
puts "*" * 50
puts "\n" * 10
