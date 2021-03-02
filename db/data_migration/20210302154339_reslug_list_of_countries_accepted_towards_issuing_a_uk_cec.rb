document = Document.find_by_content_id("28a17ff2-bc8e-4237-a8f1-6ac290d9b6eb")

edition = document.editions.published.last
Whitehall::SearchIndex.delete(edition)

document.update!(slug: "list-of-countries-accepted-towards-issuing-a-uk-FSE")

PublishingApiDocumentRepublishingWorker.new.perform(document.id)

Whitehall::SearchIndex.add(edition)
