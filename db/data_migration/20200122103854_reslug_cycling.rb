document = Document.find_by_content_id("2c9679bf-f2e7-4bc3-8b5f-a317ef5d0b5a")

edition = document.editions.published.last
Whitehall::SearchIndex.delete(edition)

document.update!(slug: "cycling-and-walking")

PublishingApiDocumentRepublishingWorker.new.perform(document.id)

Whitehall::SearchIndex.add(edition)
