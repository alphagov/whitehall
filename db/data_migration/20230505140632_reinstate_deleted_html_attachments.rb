e = Edition.find(1_432_490)
HtmlAttachment.unscoped.where(attachable_id: 1_432_490, attachable_type: "Edition").update_all(deleted: false)
PublishingApiDocumentRepublishingJob.new.perform(e.document.id)
