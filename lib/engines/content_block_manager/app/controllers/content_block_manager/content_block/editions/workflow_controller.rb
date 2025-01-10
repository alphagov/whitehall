class ContentBlockManager::ContentBlock::Editions::WorkflowController < ContentBlockManager::BaseController
  include CanScheduleOrPublish

  NEW_BLOCK_STEPS = {
    review: "review",
    edit_draft: "edit_draft",
  }.freeze

  UPDATE_BLOCK_STEPS = {
    review_links: "review_links",
    schedule_publishing: "schedule_publishing",
    review_update: "review_update",
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
      review_update
    when UPDATE_BLOCK_STEPS[:review_update]
      validate_review_page("review_update")
    when NEW_BLOCK_STEPS[:review]
      validate_review_page("review")
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

    @url = review_url

    render :review
  end

  def review_url
    content_block_manager.content_block_manager_content_block_workflow_path(
      @content_block_edition,
      step: ContentBlockManager::ContentBlock::Editions::WorkflowController::NEW_BLOCK_STEPS[:review],
    )
  end

  def review_update
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])

    validate_scheduled_edition

    @url = review_update_url

    render :review
  rescue ActiveRecord::RecordInvalid
    render :schedule_publishing
  end

  def confirmation
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])

    @confirmation_copy = ContentBlockManager::ConfirmationCopyPresenter.new(@content_block_edition)

    render :confirmation
  end

  def review_links
    @content_block_document = @content_block_edition.document
    @order = params[:order]
    @page = params[:page]

    @host_content_items = ContentBlockManager::HostContentItem.for_document(
      @content_block_document,
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

  def validate_review_page(step)
    if (step == NEW_BLOCK_STEPS[:review] || step == UPDATE_BLOCK_STEPS[:review_update]) && params[:is_confirmed].blank?
      @confirm_error_copy = I18n.t("content_block_edition.review_page.errors.confirm")
      @error_summary_errors = [{ text: @confirm_error_copy, href: "#is_confirmed-0" }]
      @url = step == NEW_BLOCK_STEPS[:review] ? review_url : review_update_url
      render "content_block_manager/content_block/editions/workflow/review"
    else
      schedule_or_publish
    end
  end
end
