class ContentBlockManager::ContentBlock::Editions::WorkflowController < ContentBlockManager::BaseController
  NEW_BLOCK_STEPS = {
    review: "review",
  }.freeze

  UPDATE_BLOCK_STEPS = {
    review_links: "review_links",
    schedule_publishing: "schedule_publishing",
  }.freeze

  def show
    step = params[:step]
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
    @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)

    case step
    when UPDATE_BLOCK_STEPS[:review_links]
      review_links
    when UPDATE_BLOCK_STEPS[:schedule_publishing]
      schedule_publishing
    when NEW_BLOCK_STEPS[:review]
      review
    end
  end

  def update
    step = params[:step]
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
    @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)

    case step
    when UPDATE_BLOCK_STEPS[:review_links]
      redirect_to content_block_manager.content_block_manager_content_block_workflow_path(id: @content_block_edition.id, step: :schedule_publishing)
    when UPDATE_BLOCK_STEPS[:schedule_publishing]
      schedule_or_publish
    when NEW_BLOCK_STEPS[:review]
      publish
    end
  end

private

  def review
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])

    render :review
  end

  def review_links
    @content_block_document = @content_block_edition.document
    @host_content_items = ContentBlockManager::GetHostContentItems.by_embedded_document(
      content_block_document: @content_block_document,
    )

    render :review_links
  end

  def schedule_publishing
    @content_block_document = @content_block_edition.document

    render :schedule_publishing
  end

  def schedule_or_publish
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
    @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)

    if params[:schedule_publishing].blank?
      @content_block_edition.errors.add(:schedule_publishing, "cannot be blank")
      raise ActiveRecord::RecordInvalid, @content_block_edition
    elsif params[:schedule_publishing] == "schedule"
      ContentBlockManager::ScheduleEditionService.new(@schema).call(@content_block_edition, scheduled_publication_params)
      message = "#{@content_block_edition.block_type.humanize} scheduled successfully"
    else
      publish and return
    end

    redirect_to content_block_manager.content_block_manager_content_block_document_path(@content_block_edition.document),
                flash: { notice: message }
  rescue ActiveRecord::RecordInvalid
    render "content_block_manager/content_block/editions/workflow/schedule_publishing"
  end

  def publish
    new_edition = ContentBlockManager::PublishEditionService.new(@schema).call(@content_block_edition)
    redirect_to content_block_manager.content_block_manager_content_block_document_path(new_edition.document),
                flash: { notice: "#{new_edition.block_type.humanize} created successfully" }
  end
end
