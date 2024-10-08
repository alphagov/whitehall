class ContentObjectStore::ContentBlock::DocumentsController < ContentObjectStore::BaseController
  def index
    @content_block_documents = ContentObjectStore::ContentBlock::Document.live
  end

  def show
    @content_block_document = ContentObjectStore::ContentBlock::Document.find(params[:id])
    @content_block_versions = @content_block_document.versions

    @host_content_items = ContentObjectStore::GetHostContentItems.by_embedded_document(
      content_block_document: @content_block_document,
    )
  end

  def new
    @schemas = ContentObjectStore::ContentBlock::Schema.all
  end

  def new_document_options_redirect
    if params[:block_type].present?
      redirect_to content_object_store.new_content_object_store_content_block_edition_path(block_type: params.require(:block_type))
    else
      redirect_to content_object_store.new_content_object_store_content_block_document_path, flash: { error: "You must select a block type" }
    end
  end
end
