old_slug = 'digital-data-and-technology-job-roles-in-government'
new_slug = 'digital-data-and-technology-profession-capability-framework'

document = Document.find_by(slug: old_slug)

if document
  # remove the most recent edition from the search index
  edition = document.editions.published.last
  Whitehall::SearchIndex.delete(edition)

  # change the slug of the document and create a redirect from the original
  document.update_attributes!(slug: new_slug)
  PublishingApiDocumentRepublishingWorker.new.perform(document.id)
end
