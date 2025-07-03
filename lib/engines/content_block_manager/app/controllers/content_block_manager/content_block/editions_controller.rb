class ContentBlockManager::ContentBlock::EditionsController < ContentBlockManager::BaseController
  include Workflow::Steps

  skip_before_action :initialize_edition_and_schema

  def new
    if params[:document_id]
      @content_block_document = ContentBlockManager::ContentBlock::Document.find(params[:document_id])
      @title = @content_block_document.title
      @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_document.block_type)
      content_block_edition = @content_block_document.latest_edition
    else
      @title = "Create content block"
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
    @content_block_edition = ContentBlockManager::CreateEditionService.new(@schema).call(edition_params, document_id: params[:document_id])
    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(id: @content_block_edition.id, step: next_step.name)
  rescue ActiveRecord::RecordInvalid => e
    @title = params[:document_id] ? e.record.document.title : "Create content block"
    @form = ContentBlockManager::ContentBlock::EditionForm.for(content_block_edition: e.record, schema: @schema)
    render "content_block_manager/content_block/editions/new"
  end

  def destroy
    edition_to_delete = ContentBlockManager::ContentBlock::Edition.find(params[:id])
    ContentBlockManager::DeleteEditionService.new.call(edition_to_delete)
    redirect_to params[:redirect_path] || content_block_manager.content_block_manager_root_path
  end

private

  def block_type_param
    params.require("content_block/edition").require("document_attributes").require(:block_type)
  end
end
