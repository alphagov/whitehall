class ContentObjectStore::ContentBlock::WorkflowController < ContentObjectStore::BaseController
  def publish
    edition = ContentObjectStore::ContentBlock::Edition.find(params[:id])
    schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(edition.document.block_type)
    new_edition = ContentObjectStore::PublishEditionService.new(
      schema,
    ).call(edition)
    redirect_to content_object_store.content_object_store_content_block_document_path(new_edition.document),
                flash: { notice: "#{new_edition.block_type.humanize} created successfully" }
    # TODO: error handling
    # else
    #   redirect_to admin_edition_path(@edition), alert: edition_publisher.failure_reason
    # end
  end
end
