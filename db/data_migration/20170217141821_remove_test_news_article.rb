doc = Document.find(333532)
edition = doc.editions.first
Whitehall.edition_services.deleter(edition).perform!
