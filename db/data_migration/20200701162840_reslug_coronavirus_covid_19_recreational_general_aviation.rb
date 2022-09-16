# Reslug parent document & attached HTML attachment

slug = "coronavirus-covid-19-recreational-general-aviation"
new_slug = "coronavirus-covid-19-general-aviation"

document = Document.find_by(slug:)
edition = document.editions.published.last
html_attachment = edition.attachments.find_by(slug:)

html_attachment.update!(slug: new_slug)
Whitehall::PublishingApi.republish_async(html_attachment)

Whitehall::SearchIndex.delete(edition)

document.update!(slug: new_slug)
PublishingApiDocumentRepublishingWorker.new.perform(document.id)

Whitehall::SearchIndex.add(edition)
