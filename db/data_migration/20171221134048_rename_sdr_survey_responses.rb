old_slug = "statistical-data-return-2012-to-2013-survey-responses"
new_slug = "statistical-data-return-survey-responses"

document = Document.find_by(slug: old_slug)

if document
  edition = document.editions.published.last

  Whitehall::SearchIndex.delete(edition)

  document.update_attributes!(slug: new_slug)
  PublishingApiDocumentRepublishingWorker.new.perform(document.id)

  puts "#{old_slug} -> #{new_slug}"
end
