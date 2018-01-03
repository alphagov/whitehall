old_slug = "regulation-committee-minutes"
new_slug = "regulation-committee-minutes-2016"

document = Document.find_by(slug: old_slug)

if document
  edition = document.editions.published.last

  Whitehall::SearchIndex.delete(edition)

  document.update_attributes!(slug: new_slug)
  PublishingApiDocumentRepublishingWorker.new.perform(document.id)

  puts "#{old_slug} -> #{new_slug}"
end
