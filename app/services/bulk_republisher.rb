class BulkRepublisher
  def republish_all_organisation_about_us_pages
    document_ids = Organisation.all.map(&:about_us).compact.pluck(:document_id)

    document_ids.each do |document_id|
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
        "bulk_republishing",
        document_id,
        true,
      )
    end
  end
end
