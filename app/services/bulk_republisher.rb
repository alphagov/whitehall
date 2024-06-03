class BulkRepublisher
  def republish_all_published_organisation_about_us_pages
    document_ids = Organisation.all.map(&:about_us).compact.pluck(:document_id)

    document_ids.each do |document_id|
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
        "bulk_republishing",
        document_id,
        true,
      )
    end
  end

  def republish_all_documents
    Document.find_each do |document|
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document.id, true)
    end
  end

  def republish_all_documents_with_pre_publication_editions
    editions = Edition.in_pre_publication_state.includes(:document)

    editions.find_each do |edition|
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", edition.document.id, true)
    end
  end

  def republish_all_documents_with_pre_publication_editions_with_html_attachments
    document_ids = Edition
      .in_pre_publication_state
      .where(id: HtmlAttachment.where(attachable_type: "Edition").select(:attachable_id))
      .pluck(:document_id)

    document_ids.each do |document_id|
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document_id, true)
    end
  end
end
