document = Document.find_by(id: 231_128)
if document
  PublishingApiDocumentRepublishingWorker.perform_async(231_128)
end
