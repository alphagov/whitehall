class ContentObjectStore::ContentBlock::Editions::StepsController < ContentObjectStore::BaseController
  VALID_STEPS = {
    review_links: "review_links",
    schedule_publishing: "schedule_publishing",
  }.freeze

  def show
    step = params[:step]
    @content_block_edition = ContentObjectStore::ContentBlock::Edition.find(params[:id])
    @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)

    case step
    when VALID_STEPS[:review_links]
      review_links
    when VALID_STEPS[:schedule_publishing]
      schedule_publishing
    end
  end

  def update
    step = params[:step]
    @content_block_edition = ContentObjectStore::ContentBlock::Edition.find(params[:id])
    @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)

    case step
    when VALID_STEPS[:review_links]
      confirm_links
    when VALID_STEPS[:schedule_publishing]
      schedule_or_publish
    end
  end

private

  def review_links
    @content_block_document = @content_block_edition.document
    @host_content_items = ContentObjectStore::GetHostContentItems.by_embedded_document(
      content_block_document: @content_block_document,
    )

    render :review_links
  end

  def confirm_links
    redirect_to content_object_store.content_object_store_content_block_step_path(id: @content_block_edition.id, step: :schedule_publishing)
  end

  def schedule_publishing
    @content_block_document = @content_block_edition.document

    render :schedule_publishing
  end

  def schedule_or_publish
    @content_block_edition = ContentObjectStore::ContentBlock::Edition.find(params[:id])
    @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)

    if params[:schedule_publishing].blank?
      @content_block_edition.errors.add(:schedule_publishing, "cannot be blank")
      raise ActiveRecord::RecordInvalid, @content_block_edition
    elsif params[:schedule_publishing] == "schedule"
      ContentObjectStore::ScheduleEditionService.new(@schema).call(@content_block_edition, scheduled_publication_params)
      message = "#{@content_block_edition.block_type.humanize} scheduled successfully"
    else
      ContentObjectStore::PublishEditionService.new(@schema).call(@content_block_edition)
      message = "#{@content_block_edition.block_type.humanize} created successfully"
    end

    redirect_to content_object_store.content_object_store_content_block_document_path(@content_block_edition.document),
                flash: { notice: message }
  rescue ActiveRecord::RecordInvalid
    render "content_object_store/content_block/editions/steps/schedule_publishing"
  end
end
