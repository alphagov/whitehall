ids = [
  42_786,
  54_892,
  309_262,
]
Document.where(id: ids).each do |document|
  PublishingApiDocumentRepublishingWorker
    .perform_async_in_queue("bulk_republishing", document.id)
end
