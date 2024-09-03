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

  def update
    content_block_edition = ContentObjectStore::ContentBlock::Edition.find(params[:id])
    @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(content_block_edition.document.block_type)

    ContentObjectStore::SchedulePublishingWorker.dequeue(content_block_edition)

    new_edition = edition_params
    if params[:schedule_publishing] == "schedule"
      new_edition = edition_params.merge!(scheduled_publication_params)
      new_content_block_edition = ContentObjectStore::ScheduleEditionService.new(
        content_block_edition,
      ).call(new_edition)
      flash_text = "#{@schema.name} scheduled successfully"
    else
      new_content_block_edition = ContentObjectStore::UpdateEditionService.new(
        @schema,
        content_block_edition,
      ).call(new_edition)
      flash_text = "#{@schema.name} changed and published successfully"
    end

    redirect_to content_object_store.content_object_store_content_block_document_path(new_content_block_edition.document),
                flash: { notice: flash_text }
  rescue ActiveRecord::RecordInvalid => e
    @content_block_edition = e.record
    @content_block_document = content_block_edition.document
    @edition_params = new_edition

    render "content_object_store/content_block/editions/schedule_publishing"
  end
end
