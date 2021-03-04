attachments = Attachment.where(locale: "pa-ur")

document_ids = Edition.distinct.where(id: attachments.select(:attachable_id)).pluck(:document_id)

attachments.update_all(locale: "pa-pk")

document_ids.each do |id|
  PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", id)
end
