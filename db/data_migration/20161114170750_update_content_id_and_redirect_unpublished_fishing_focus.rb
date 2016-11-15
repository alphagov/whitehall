doc = Document.find(199968)
new_content_id = SecureRandom.uuid

doc.content_id = new_content_id
doc.save(validate: false)

PublishingApiDraftWorker.new.perform("DocumentCollection", doc.latest_edition.id)
PublishingApiRedirectWorker.new.perform(doc.content_id, "/government/publications/fishing-focus", :en, true)
