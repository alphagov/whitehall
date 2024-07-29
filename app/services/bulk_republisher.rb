class BulkRepublisher
  include Admin::RepublishingHelper

  def republish_all_published_organisation_about_us_pages
    document_ids = Organisation.all.map(&:about_us).compact.pluck(:document_id)
    republish_all_documents_by_ids(document_ids)
  end

  def republish_all_documents
    document_ids = Document.pluck(:id)
    republish_all_documents_by_ids(document_ids)
  end

  def republish_all_documents_with_pre_publication_editions
    document_ids = Edition.in_pre_publication_state.pluck(:document_id)
    republish_all_documents_by_ids(document_ids)
  end

  def republish_all_documents_with_pre_publication_editions_with_html_attachments
    document_ids = Edition
      .in_pre_publication_state
      .where(id: HtmlAttachment.where(attachable_type: "Edition").select(:attachable_id))
      .pluck(:document_id)

    republish_all_documents_by_ids(document_ids)
  end

  def republish_all_documents_with_publicly_visible_editions_with_attachments
    document_ids = Edition
      .publicly_visible
      .where(id: Attachment.where(attachable_type: "Edition").select(:attachable_id))
      .pluck(:document_id)

    republish_all_documents_by_ids(document_ids)
  end

  def republish_all_documents_with_publicly_visible_editions_with_html_attachments
    document_ids = Edition
      .publicly_visible
      .where(id: HtmlAttachment.where(attachable_type: "Edition").select(:attachable_id))
      .pluck(:document_id)

    republish_all_documents_by_ids(document_ids)
  end

  def republish_all_by_type(content_type)
    begin
      content_type_klass = content_type.constantize
      raise NameError unless republishable_content_types.include?(content_type)
    rescue NameError
      raise "Unknown content type #{content_type}\nCheck the GOV.UK developer documentation for a list of acceptable document types: https://docs.publishing.service.gov.uk/manual/republishing-content.html#whitehall"
    end

    if non_editionable_content_types.include?(content_type)
      republish_all_by_non_editionable_type(content_type_klass)
    else
      republish_all_documents_by_ids(content_type_klass.pluck(:document_id))
    end
  end

  def republish_all_documents_by_organisation(organisation)
    raise "Argument must be an organisation" unless organisation.is_a?(Organisation)

    document_ids = Edition
      .latest_edition
      .in_organisation(organisation)
      .pluck(:document_id)

    republish_all_documents_by_ids(document_ids)
  end

  def republish_all_documents_by_ids(ids)
    ids.each do |id|
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", id, true)
    end
  end

private

  def republish_all_by_non_editionable_type(content_type_klass)
    content_type_klass.find_each(&:bulk_republish_to_publishing_api_async)
  end
end
