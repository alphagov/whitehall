class ContentObjectStore::ContentBlock::DocumentsController < ContentObjectStore::BaseController
  def index
    @content_block_documents = ContentObjectStore::ContentBlock::Document.all
  end

  def show
    @content_block_document = ContentObjectStore::ContentBlock::Document.find(params[:id])
    @content_block_versions = @content_block_document.versions

    linked_item_service = ContentObjectStore::GetLinkedContentItems.new(
      content_block_document: @content_block_document,
      page: params[:page],
    )

    @linked_content_items = linked_item_service.items
    @page_data = linked_item_service.page_data
  end
end
