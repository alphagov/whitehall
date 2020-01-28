document = Document.find_by(slug: "ww1-south-african-vc-recipient-henry-harry-greenwood")

document.update(slug: "ww1-vc-recipient-henry-harry-greenwood")

PublishingApiDocumentRepublishingWorker.perform_async(document.id)
