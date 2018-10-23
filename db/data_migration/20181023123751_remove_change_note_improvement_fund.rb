document = Document.find_by(content_id: "6022c077-7631-11e4-a3cb-005056011aef")
edition = document.editions.published.last

if edition.change_note == "Application round for 2019 to 2020 funding now open."
  edition[:minor_change] = true
  edition.save(validate: false)
  PublishingApiDocumentRepublishingWorker.new.perform(document.id)
end