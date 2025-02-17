class ContentBlockManager::ContentBlock::EditionsController < ContentBlockManager::BaseController
  def new
    if params[:document_id]
      @title = "Edit a content block"
      @content_block_document = ContentBlockManager::ContentBlock::Document.find(params[:document_id])
      @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_document.block_type)
      content_block_edition = @content_block_document.latest_edition
    else
      @title = "Create a content block"
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
    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(id: new_edition.id, step: next_step)
  rescue ActiveRecord::RecordInvalid => e
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

  def next_step
    if @schema.subschemas.any?
      "embedded_#{@schema.subschemas.first.id}"
    elsif params[:document_id]
      :review_links
    else
      :review
    end
  end
end
