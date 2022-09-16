# Reslug parent document & attached HTML attachment

slug = "accessing-government-secured-flu-vaccines-guidance-for-gps-for-2021-to-2022"
new_slug = "accessing-government-secured-flu-vaccines-guidance-for-primary-care-in-England-for-2021-to-2022"

document = Document.find_by(slug:)
edition = document.editions.published.last
html_attachment = edition.attachments.last

html_attachment.update!(slug: new_slug)
Whitehall::PublishingApi.republish_async(html_attachment)

Whitehall::SearchIndex.delete(edition)

document.update!(slug: new_slug)
PublishingApiDocumentRepublishingWorker.new.perform(document.id)

Whitehall::SearchIndex.add(edition)
