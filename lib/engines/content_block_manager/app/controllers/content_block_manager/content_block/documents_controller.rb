class ContentBlockManager::ContentBlock::DocumentsController < ContentBlockManager::BaseController
  def index
    @filters = params_filters
    @content_block_documents = ContentBlockManager::ContentBlock::Document::DocumentFilter.new(@filters).documents
  end

  def show
    @content_block_document = ContentBlockManager::ContentBlock::Document.find(params[:id])
    @content_block_versions = @content_block_document.versions

    @host_content_items = ContentBlockManager::GetHostContentItems.by_embedded_document(
      content_block_document: @content_block_document,
    )
  end

  def new
    @schemas = ContentBlockManager::ContentBlock::Schema.all
  end

  def new_document_options_redirect
    if params[:block_type].present?
      redirect_to content_block_manager.new_content_block_manager_content_block_edition_path(block_type: params.require(:block_type))
    else
      redirect_to content_block_manager.new_content_block_manager_content_block_document_path, flash: { error: "You must select a block type" }
    end
  end

private

  def params_filters
    params.slice(:title)
          .permit!
          .to_h
  end
end
