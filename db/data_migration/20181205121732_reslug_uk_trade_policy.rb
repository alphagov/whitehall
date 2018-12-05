# get document by slug and document_type
document = Document.find_by(slug: 'preparing-for-a-uk-trade-policy-a-guide-to-trade-legislation', document_type: 'Publication')

if document
  # remove the most recent edition from the search index
  edition = document.editions.published.last
  Whitehall::SearchIndex.delete(edition)

  # change the slug of the document and create a redirect from the original
  document.update_attributes!(slug: 'a-uk-trade-policy-a-guide-to-trade-legislation')
  PublishingApiDocumentRepublishingWorker.new.perform(document.id)
end
