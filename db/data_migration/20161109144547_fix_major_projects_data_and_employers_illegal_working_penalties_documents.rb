# This is a document that is being linked from /government/collections/major-projects-data.
d = Document.find(168857)

# Here's the issue:
# > d.editions.map(&:state)
# ["superseded", "draft", "published"]
#                ^^^^^^^ - This is wrong and shouldn't happen today, let's fix it.
corrupted_edition = d.editions[1]
corrupted_edition.state = 'superseded'
corrupted_edition.unpublishing.destroy!

# The validate: false is necessary to get around the lack of a policy area on this document.
corrupted_edition.save(validate: false)

PublishingApiDocumentRepublishingWorker.new.perform(d.id)

# This is a document that is being linked from /government/collections/employers-illegal-working-penalties
d = Document.find(216539)

# Here's the issue:
# > d.editions.map(&:state)
# ["superseded", "superseded", "draft", "published"]
#                              ^^^^^^^ - As above, this is wrong.
corrupted_edition = d.editions[2]
corrupted_edition.state = 'superseded'
corrupted_edition.unpublishing.destroy!

# This one doesn't need validate: false.
corrupted_edition.save!

PublishingApiDocumentRepublishingWorker.new.perform(d.id)
