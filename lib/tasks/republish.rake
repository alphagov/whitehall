desc "Republish all documents with non-english html attachments"
task republish_non_english_html_attachments: :environment do
  document_ids = HtmlAttachment.where.not(deleted: true)
    .where.not(locale: "en")
    .where.not(locale: nil) # HtmlAttachment#sluggable_locale? treats nil locales the same as English
    .map { |attachment|
      attachment.attachable.document.id
    }.uniq

  puts "#{document_ids.length} items to republish"

  document_ids.each do |document_id|
    PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
      "bulk_republishing",
      document_id,
      true,
    )
  end
end
