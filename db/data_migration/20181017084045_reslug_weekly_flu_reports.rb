# There are two different types of document at this slug hence the doc type criteria
document = Document.find_by(slug: 'weekly-national-flu-reports', document_type: 'Publication')
# remove the most recent edition from the search index
edition = document.editions.published.last
Whitehall::SearchIndex.delete(edition)

# change the slug of the document and create a redirect from the original
document.update_attributes!(slug: 'weekly-national-flu-reports-2017-to-2018-season')
PublishingApiDocumentRepublishingWorker.new.perform(document.id)
