slug_changes = [
  {
    slug: "vietnam-list-of-english-speaking-lawyers",
    new_slug: "vietnam-list-of-medical-facilities-in-hanoi-and-northern-provinces",
  },
  {
    slug: "vietnam-lists-of-lawyers-and-medical-facilities-in-ho-chi-minh-city-and-southern-provinces",
    new_slug: "vietnam-list-of-medical-facilities-in-ho-chi-minh-city-and-southern-provinces",
  },
]

slug_changes.each do |slug_change|
  document = Document.find_by(slug: slug_change[:slug])

  edition = document.editions.published.last
  Whitehall::SearchIndex.delete(edition)

  document.update!(slug: slug_change[:new_slug])

  PublishingApiDocumentRepublishingWorker.new.perform(document.id)

  Whitehall::SearchIndex.add(edition)
end
