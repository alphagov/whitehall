current_slug = 'initial-teacher-training-allocations-academic-year-2016-to-2017'
new_slug = 'initial-teacher-training-allocations-academic-year-2017-to-2018'

document = Document.find_by(slug: current_slug)
document.update_attribute(:slug, new_slug)

PublishingApiDocumentRepublishingWorker.perform_async(document.id)
