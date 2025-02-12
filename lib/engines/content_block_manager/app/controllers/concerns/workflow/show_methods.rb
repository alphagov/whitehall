module Workflow::ShowMethods
  extend ActiveSupport::Concern

  def edit_draft
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
    @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)
    @form = ContentBlockManager::ContentBlock::EditionForm::Edit.new(content_block_edition: @content_block_edition, schema: @schema)

    render :edit_draft
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

  def review
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])

    render :review
  end

  def confirmation
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])

    @confirmation_copy = ContentBlockManager::ConfirmationCopyPresenter.new(@content_block_edition)

    render :confirmation
  end

  def back_path
    if current_step.name == "review" && @content_block_edition.document.is_new_block?
      content_block_manager.content_block_manager_content_block_documents_path
    else
      return nil unless previous_step

      content_block_manager.content_block_manager_content_block_workflow_path(
        @content_block_edition,
        step: previous_step.name,
      )
    end
  end
  included do
    helper_method :back_path
  end
end
