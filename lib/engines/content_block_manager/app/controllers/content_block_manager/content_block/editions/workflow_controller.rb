class ContentBlockManager::ContentBlock::Editions::WorkflowController < ContentBlockManager::BaseController
  NEW_BLOCK_STEPS = {
    review: "review",
    edit_draft: "edit_draft",
  }.freeze

  UPDATE_BLOCK_STEPS = {
    review_links: "review_links",
    schedule_publishing: "schedule_publishing",
  }.freeze

  SHARED_STEPS = {
    confirmation: "confirmation",
  }.freeze

  def show
    step = params[:step]
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
    @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)

    case step
    when NEW_BLOCK_STEPS[:edit_draft]
      edit_draft
    when UPDATE_BLOCK_STEPS[:review_links]
      review_links
    when UPDATE_BLOCK_STEPS[:schedule_publishing]
      schedule_publishing
    when NEW_BLOCK_STEPS[:review]
      review
    when SHARED_STEPS[:confirmation]
      confirmation
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

  def edit_draft
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
    @form = ContentBlockManager::ContentBlock::EditionForm.for(
      content_block_edition: @content_block_edition,
      schema: @schema,
    )

    render "content_block_manager/content_block/editions/new"
  end

  def review
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])

    render :review
  end

  def confirmation
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])

    if params[:is_scheduled]
      @panel_copy = "Your content block is scheduled for change"
      @paragraph_copy = "Your content block has been edited and is now scheduled for change."
    else
      @panel_copy = "Your content block is available for use"
      @paragraph_copy = "Your content block has been published and is now available for use."
    end

    render :confirmation
  end

  def review_links
    @content_block_document = @content_block_edition.document
    @order = params[:order]
    @page = params[:page]

    @host_content_items = ContentBlockManager::GetHostContentItems.by_embedded_document(
      content_block_document: @content_block_document,
      order: @order,
      page: @page,
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
    else
      publish and return
    end

    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(id: @content_block_edition.id,
                                                                                        step: :confirmation,
                                                                                        is_scheduled: true)
  rescue ActiveRecord::RecordInvalid
    render "content_block_manager/content_block/editions/workflow/schedule_publishing"
  end

  def publish
    new_edition = ContentBlockManager::PublishEditionService.new.call(@content_block_edition)
    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(id: new_edition.id, step: :confirmation)
  end
end
