document_scope = Document.where(
  id: Publication.where(state: %w(draft published withdrawn)).pluck(:id)
)

lowest_document_id_for_this_republish = 290000
document_scope = document_scope.where(
  "id > ?", lowest_document_id_for_this_republish
).order(id: :desc)

document_scope.pluck(:id).each do |document_id|
  print "."
  PublishingApiDocumentRepublishingWorker
    .perform_async_in_queue("bulk_republishing", document_id)
end
