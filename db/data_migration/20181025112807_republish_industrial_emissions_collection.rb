document = Document.find_by(id: 231128)
if document
  PublishingApiDocumentRepublishingWorker.perform_async(231128)
end
