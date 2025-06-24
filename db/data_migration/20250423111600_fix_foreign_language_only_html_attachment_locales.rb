# Update the locale of any HTML attachments associated with foreign language only documents to match the document's primary locale
consultations = Consultation.joins(:attachments)
                            .where("primary_locale != \"en\"")
                            .where(attachments: { locale: nil, type: "HTMLAttachment" })

consultations.each do |consultation|
  consultation.html_attachments.each do |attachment|
    attachment.locale = consultation.primary_locale
    attachment.save!
  end
end

consultations.pluck(:document_id).uniq.each do |document_id|
  PublishingApiDocumentRepublishingWorker.perform_async(document_id)
end
