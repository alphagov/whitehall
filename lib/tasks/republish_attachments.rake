desc "Republish all documents with non-pdf attachments"
task :republish_attachments, %i[content_type weeks_ago] => :environment do |_, args|
  content_type = args[:content_type]
  weeks_ago = args[:weeks_ago]

  query = Attachment.joins(:attachment_data)
                    .joins("JOIN editions ON editions.id = attachments.attachable_id AND attachments.attachable_type = 'Edition'")
                    .where.not(deleted: true)
                    .where.not(attachable: nil)
                    .where(editions: { state: "published" })

  query = query.where(attachment_data: { content_type: }) if content_type
  query = query.where("editions.public_timestamp >= :start_date", { start_date: Time.zone.now - weeks_ago.to_i.weeks }) if weeks_ago

  document_ids = query.distinct.pluck(:document_id)

  puts "#{document_ids.length} items to republish"

  document_ids.each do |document_id|
    PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document_id, true)
  end
end
