DataHygiene::PublishingApiDocumentRepublisher
  .new(Consultation)
  .perform

Consultation.publicly_visible.each do |consultation|
  opening_at = consultation.opening_at
  closing_at = consultation.closing_at
  document_id = consultation.document.id

  if opening_at.try(:future?)
    PublishingApiDocumentRepublishingWorker
      .perform_at(opening_at, document_id)
  end

  if closing_at.try(:future?)
    PublishingApiDocumentRepublishingWorker
      .perform_at(closing_at, document_id)
  end
end
