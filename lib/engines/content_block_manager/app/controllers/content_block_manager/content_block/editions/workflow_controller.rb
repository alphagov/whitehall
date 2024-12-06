class ContentBlockManager::ContentBlock::Editions::WorkflowController < ContentBlockManager::BaseController
  include CanScheduleOrPublish

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

  def context
    "Edit content block"
  end
  helper_method :context

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

    confirmation_copy

    render :confirmation
  end

  def confirmation_copy
    if params[:is_scheduled]
      @panel_copy = "#{@content_block_edition.block_type.humanize} scheduled to publish on #{I18n.l(@content_block_edition.scheduled_publication, format: :long_ordinal)}"
      @paragraph_copy = "You can now view the updated schedule of the content block."
    elsif more_than_one_edition?
      @panel_copy = "#{@content_block_edition.block_type.humanize} published"
      @paragraph_copy = "You can now view the updated content block."
    else
      @panel_copy = "#{@content_block_edition.block_type.humanize} created"
      @paragraph_copy = "You can now view the content block."
    end
  end

  def more_than_one_edition?
    @content_block_edition.document.editions.count > 1
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

  REVIEW_ERROR = Data.define(:attribute, :full_message)

  def publish
    if params[:step] == NEW_BLOCK_STEPS[:review] && params[:is_confirmed].blank?
      @confirm_error_copy = "Confirm details are correct"
      @error_summary_errors = [{ text: @confirm_error_copy, href: "#is_confirmed-0" }]
      render "content_block_manager/content_block/editions/workflow/review"
    else
      new_edition = ContentBlockManager::PublishEditionService.new.call(@content_block_edition)
      redirect_to content_block_manager.content_block_manager_content_block_workflow_path(id: new_edition.id, step: :confirmation)
    end
  end
end
