desc "Republish all documents with attachments for organisations"
task repubish_docs_with_attachments: :environment do
  organisations = Organisation.all

  organisations.each do |org|
    editions = org.editions.publicly_visible
    puts "Total editions for #{org.slug}: #{editions.count}"
    editions_with_attachments = editions.where(
      id: Attachment.where(accessible: [false, nil], attachable_type: "Edition").select("attachable_id"),
    )
    puts "Enqueueing #{editions_with_attachments.count} editions with attachments for #{org.slug}"
    editions_with_attachments.joins(:document).distinct.pluck("documents.id").each do |document_id|
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document_id, true)
    end
    puts "Finished enqueueing items for #{org.slug}"
  end
end
