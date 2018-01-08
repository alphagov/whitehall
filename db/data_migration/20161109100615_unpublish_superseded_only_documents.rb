# DocumentCollection sync checks are throwing up some errors as follow:
# "documents shouldn't contain 'uuid'"
# Searching for these documents by uuid reveals a document in a strange state:
# The document will have only 1 edition and that edition state will be superseded
#
# To fix this we are going to manually set the state to `published` and then
# send them throuh the EditionUnpublisher to unpublish them with a PublishedInError
# id and reason. We have to first set the state to `published` because Edition
# workflow only allows certain state transitions.
#
# We also send them through the PublishingApi to resync data in the content store
content_ids = ['5f5299be-7631-11e4-a3cb-005056011aef', '5d8ff850-7631-11e4-a3cb-005056011aef']
documents = Document.where(content_id: content_ids)

documents.each do |document|
  first_edition = document.editions.first
  first_edition.state = "published"
  first_edition.save

  unpublisher = EditionUnpublisher.new(
    first_edition,
    unpublishing: { unpublishing_reason_id: UnpublishingReason::PublishedInError.id, explanation: 'Published in error' }
  )
  puts "about to unpublish #{document.content_id}"
  unpublisher.perform!
  puts 'unpublished in Whitehall'
  puts 'republishing to publishing api'
  PublishingApiDocumentRepublishingWorker.new.perform(document.id)
  puts 'done'
end
