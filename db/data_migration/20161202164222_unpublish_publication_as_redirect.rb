doc = Document.find(8463)
PublishingApiRedirectWorker.new.perform(doc.content_id, "/homelessness-data-notes-and-definitions", :en, true)
