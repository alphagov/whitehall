document = Document.find_by(slug: "roads-managed-by-the-highways-agency")

document.update_column(:slug, "roads-managed-by-highways-england")

PublishingApiDocumentRepublishingWorker.perform_async(document.id)
