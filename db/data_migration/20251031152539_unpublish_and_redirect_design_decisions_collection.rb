unpublishing_params = { unpublishing_reason_id: UnpublishingReason::CONSOLIDATED_ID, alternative_url: "https://www.gov.uk/designs-decisions", explanation: "Redirect to designs decisions finder" }

collection = Document.find_by_content_id("5f5961ca-7631-11e4-a3cb-005056011aef").latest_edition

child_document_content_ids = collection.groups.map(&:documents).flatten.map(&:content_id)

all_documents_deleted = true
collection_deleted = true

# Unpublish and redirect all documents in the collection
child_document_content_ids.each do |content_id|
  edition = Document.find_by_content_id(content_id).latest_edition
  unpublisher = Whitehall.edition_services.unpublisher(
    edition,
    unpublishing: unpublishing_params,
  )
  success = unpublisher.perform!
  unless success
    all_documents_deleted = false
    logger.info("Failed to unpublish #{content_id} due to: #{unpublisher.failure_reason}")
  end
end

# Unpublish and redirect the collection itself
if all_documents_deleted
  unpublisher = Whitehall.edition_services.unpublisher(
    collection,
    unpublishing: unpublishing_params,
  )
  success = unpublisher.perform!
  unless success
    collection_deleted = false
    logger.info("Failed to unpublish collection #{collection.content_id} due to: #{unpublisher.failure_reason}")
  end
end

if all_documents_deleted && collection_deleted
  logger.info("unpublished #{child_document_content_ids.count} documents and their collection")
else
  logger.info("collection migration failed")
end
