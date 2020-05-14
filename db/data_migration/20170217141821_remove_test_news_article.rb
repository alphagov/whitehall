doc = Document.find(333_532)
edition = doc.editions.first
Whitehall.edition_services.deleter(edition).perform!
