class ContentObjectStore::ContentBlock::EditionsController < ContentObjectStore::BaseController
  def new
    if params[:document_id]
      @content_block_document = ContentObjectStore::ContentBlock::Document.find(params[:document_id])
      @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(@content_block_document.block_type)
      content_block_edition = @content_block_document.latest_edition
    else
      @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(params[:block_type].underscore)
      content_block_edition = ContentObjectStore::ContentBlock::Edition.new
    end
    @form = ContentObjectStore::ContentBlock::EditionForm.for(
      content_block_edition:,
      schema: @schema,
    )
  end

  def create
    @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(block_type_param)
    new_edition = ContentObjectStore::CreateEditionService.new(@schema).call(edition_params, document_id: params[:document_id])
    step = params[:document_id] ? ContentObjectStore::ContentBlock::Editions::WorkflowController::UPDATE_BLOCK_STEPS[:review_links] : ContentObjectStore::ContentBlock::Editions::WorkflowController::NEW_BLOCK_STEPS[:review]
    redirect_to content_object_store.content_object_store_content_block_workflow_path(id: new_edition.id, step:)
  rescue ActiveRecord::RecordInvalid => e
    @form = ContentObjectStore::ContentBlock::EditionForm.for(content_block_edition: e.record, schema: @schema)
    render "content_object_store/content_block/editions/new"
  end

private

  def block_type_param
    params.require("content_block/edition").require("document_attributes").require(:block_type)
  end
end
