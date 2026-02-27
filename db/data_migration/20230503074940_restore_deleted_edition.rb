# This restores an edition that was deleted by a user in error
edition = Edition.unscoped.find(1_432_490)
edition.update!(state: "draft")
PublishingApiDocumentRepublishingJob.new.perform(edition.document.id)
