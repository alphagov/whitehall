module Workflow::ShowMethods
  extend ActiveSupport::Concern

  SHOW_ACTIONS = {
    edit_draft: :edit_draft,
    review_links: :review_links,
    schedule_publishing: :schedule_publishing,
    internal_note: :internal_note,
    change_note: :change_note,
    review: :review,
    review_update: :review_update,
    confirmation: :confirmation,
  }.freeze

  def edit_draft
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
    @form = ContentBlockManager::ContentBlock::EditionForm.for(
      content_block_edition: @content_block_edition,
      schema: @schema,
    )

    render "content_block_manager/content_block/editions/new"
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

  def internal_note
    @content_block_document = @content_block_edition.document

    render :internal_note
  end

  def change_note
    @content_block_document = @content_block_edition.document

    render :change_note
  end

  def review_update
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])

    @url = review_update_url

    render :review
  end

  def review
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])

    @url = review_url

    render :review
  end

  def confirmation
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])

    @confirmation_copy = ContentBlockManager::ConfirmationCopyPresenter.new(@content_block_edition)

    render :confirmation
  end
end
