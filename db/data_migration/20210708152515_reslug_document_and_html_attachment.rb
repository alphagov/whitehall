# Reslug parent document & attached HTML attachment

slug = "react-1-study-of-coronavirus-transmission-june-2021-final-results"
new_slug = "react-1-study-of-coronavirus-transmission-may-2021-final-results"

document = Document.find_by(slug:)
edition = document.editions.published.last
html_attachment = edition.attachments.find_by(slug:)

html_attachment.update!(slug: new_slug)
Whitehall::PublishingApi.republish_async(html_attachment)

Whitehall::SearchIndex.delete(edition)

document.update!(slug: new_slug)
PublishingApiDocumentRepublishingWorker.new.perform(document.id)

Whitehall::SearchIndex.add(edition)
