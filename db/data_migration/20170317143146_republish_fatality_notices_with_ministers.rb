ids = [
  42786,
  54892,
  309262
]
Document.where(id: ids).each do |document|
  PublishingApiDocumentRepublishingWorker
    .perform_async_in_queue("bulk_republishing", document.id)
end
