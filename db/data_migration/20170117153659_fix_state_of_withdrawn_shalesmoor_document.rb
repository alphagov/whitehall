edition = Document.where(slug: 'collision-at-shalesmoor-tram-stop').first.editions.first
edition.state = 'published'
edition.save
