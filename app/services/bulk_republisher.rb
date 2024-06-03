class BulkRepublisher
  def republish_all_published_organisation_about_us_pages
    document_ids = Organisation.all.map(&:about_us).compact.pluck(:document_id)
    republish_by_document_ids(document_ids)
  end

  def republish_all_documents
    document_ids = Document.pluck(:id)
    republish_by_document_ids(document_ids)
  end

  def republish_all_documents_with_pre_publication_editions
    document_ids = Edition.in_pre_publication_state.pluck(:document_id)
    republish_by_document_ids(document_ids)
  end

  def republish_all_documents_with_pre_publication_editions_with_html_attachments
    document_ids = Edition
      .in_pre_publication_state
      .where(id: HtmlAttachment.where(attachable_type: "Edition").select(:attachable_id))
      .pluck(:document_id)

    republish_by_document_ids(document_ids)
  end

  def republish_all_documents_with_publicly_visible_editions_with_html_attachments
    document_ids = Edition
      .publicly_visible
      .where(id: HtmlAttachment.where(attachable_type: "Edition").select(:attachable_id))
      .pluck(:document_id)

    republish_by_document_ids(document_ids)
  end

private

  def republish_by_document_ids(document_ids)
    document_ids.each do |document_id|
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document_id, true)
    end
  end
end
