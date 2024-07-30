class ContentObjectStore::ContentBlock::DocumentsController < ContentObjectStore::BaseController
  def index
    @content_block_documents = ContentObjectStore::ContentBlock::Document.all
  end

  def show
    @content_block_document = ContentObjectStore::ContentBlock::Document.find(params[:id])
    @content_block_versions = @content_block_document.versions
  end
end
