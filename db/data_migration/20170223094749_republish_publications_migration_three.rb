document_scope = Document.where(
  id: Publication.where(state: %w(draft published withdrawn)).pluck(:document_id)
)

lowest_id_for_this_republish = 0
highest_id_for_this_republish = 260000
document_scope = document_scope.where(
  id: lowest_id_for_this_republish..highest_id_for_this_republish
).order(id: :desc)

puts "Republishing #{document_scope.count} documents"

document_scope.pluck(:id).each do |document_id|
  print "."
  PublishingApiDocumentRepublishingWorker
    .perform_async_in_queue("bulk_republishing", document_id)
end
