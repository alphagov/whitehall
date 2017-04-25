document_collection = DocumentCollection.find(719471)
document = document_collection.document

document.update_attributes(slug: "home-office-ministers-hospitality-data")

PublishingApiDocumentRepublishingWorker.perform_async(document.id)
