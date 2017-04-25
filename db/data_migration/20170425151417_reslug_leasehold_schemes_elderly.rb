document = Document.find_by(slug: "limit-on-the-management-element-of-the-lse-service-charge-for-2016-to-2017")

document.update_attributes(slug: "leasehold-schemes-for-the-elderly-management-fee-limit")

PublishingApiDocumentRepublishingWorker.perform_async(document.id)
