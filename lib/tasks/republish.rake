desc "Republish all documents with non-english html attachments"
task republish_non_english_html_attachments: :environment do
  HtmlAttachment.where.not(deleted: true)
  .where.not(locale: "en")
  .where.not(locale: nil) # HtmlAttachment#sluggable_locale? treats nil locales the same as English
  .each do |attachment|
    PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
      "bulk_republishing",
      attachment.attachable.document.id,
      true,
    )
  end
end
