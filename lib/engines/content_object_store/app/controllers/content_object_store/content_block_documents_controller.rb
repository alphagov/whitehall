class ContentObjectStore::ContentBlockDocumentsController < ContentObjectStore::BaseController
  def index
    @content_block_documents = ContentObjectStore::ContentBlockDocument.all
  end

  def show
    @content_block_document = ContentObjectStore::ContentBlockDocument.find(params[:id])
    @content_block_versions = ContentObjectStore::ContentBlockVersion.where(item: @content_block_document.content_block_editions.last)
  end
end
