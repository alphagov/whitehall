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

  def republish_all_individual_pages
    republishable_pages.each do |page|
      PresentPageToPublishingApiWorker.perform_async(page[:presenter])
    end
  end

  def republish_all_non_editionable_content
    non_editionable_content_types.each do |type|
      republish_all_by_non_editionable_type(type)
    end
  end

  def republish_all_by_type(content_type)
    error_message = "Unknown content type #{content_type}\n" \
                    "Check the GOV.UK developer documentation for a list of acceptable document types: " \
                    "https://docs.publishing.service.gov.uk/manual/republishing-content.html#whitehall"

    raise NameError, error_message unless republishable_content_types.include?(content_type)

    if non_editionable_content_types.include?(content_type)
      republish_all_by_non_editionable_type(content_type)
    else
      republish_all_by_editionable_type(content_type)
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

  def republish_all_by_non_editionable_type(content_type)
    content_type_klass = content_type.constantize
    content_type_klass.find_each(&:bulk_republish_to_publishing_api_async)
  end

  def republish_all_by_editionable_type(content_type)
    republishable_document_ids = Edition
                                   .joins("INNER JOIN documents ON documents.latest_edition_id = editions.id")
                                   .where(republishable_editions_predicate(content_type)
                                            .or(republishable_standard_editions_predicate(content_type)))
                                   .pluck("documents.id")

    republish_all_documents_by_ids(republishable_document_ids)
  end

  def republishable_editions_predicate(content_type)
    table = Edition.arel_table
    table[:type].eq(content_type)
  end

  def republishable_standard_editions_predicate(content_type)
    table = Edition.arel_table
    configurable_document_types_for_schema = ConfigurableDocumentType.all
                                                                     .select { |configurable_type| configurable_type.key == content_type.underscore }
                                                                     .map(&:key)

    if configurable_document_types_for_schema
      table[:type].eq("StandardEdition").and(table[:configurable_document_type].in(configurable_document_types_for_schema))
    else
      Arel.sql("FALSE")
    end
  end
end
