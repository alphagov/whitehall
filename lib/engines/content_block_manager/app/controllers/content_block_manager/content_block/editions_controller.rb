class ContentBlockManager::ContentBlock::EditionsController < ContentBlockManager::BaseController
  def new
    if params[:document_id]
      @content_block_document = ContentBlockManager::ContentBlock::Document.find(params[:document_id])
      @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_document.block_type)
      content_block_edition = @content_block_document.latest_edition
    else
      @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(params[:block_type].underscore)
      content_block_edition = ContentBlockManager::ContentBlock::Edition.new
    end
    @form = ContentBlockManager::ContentBlock::EditionForm.for(
      content_block_edition:,
      schema: @schema,
    )
  end

  def create
    @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(block_type_param)
    new_edition = ContentBlockManager::CreateEditionService.new(@schema).call(edition_params, document_id: params[:document_id])
    step = params[:document_id] ? ContentBlockManager::ContentBlock::Editions::WorkflowController::UPDATE_BLOCK_STEPS[:review_links] : ContentBlockManager::ContentBlock::Editions::WorkflowController::NEW_BLOCK_STEPS[:review]
    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(id: new_edition.id, step:)
  rescue ActiveRecord::RecordInvalid => e
    @form = ContentBlockManager::ContentBlock::EditionForm.for(content_block_edition: e.record, schema: @schema)
    render "content_block_manager/content_block/editions/new"
  end

private

  def block_type_param
    params.require("content_block/edition").require("document_attributes").require(:block_type)
  end
end
