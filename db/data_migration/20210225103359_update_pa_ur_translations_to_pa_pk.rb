translations = Edition::Translation.where(locale: "pa-ur")

document_ids = Edition.distinct.where(id: translations.select(:edition_id)).pluck(:document_id)

translations.update_all(locale: "pa-pk")

document_ids.each do |id|
  PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", id)
end
