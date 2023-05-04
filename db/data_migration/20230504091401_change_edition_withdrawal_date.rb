# This changes the withdrawal date of a specific edition, as requested by the publisher
edition = Edition.find(1_433_080)
edition.unpublishing.update!(unpublished_at: "2023-04-03")
PublishingApiDocumentRepublishingWorker.new.perform(edition.document.id)
