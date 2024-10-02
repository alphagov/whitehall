class ContentObjectStore::ContentBlock::DocumentsController < ContentObjectStore::BaseController
  def index
    @content_block_documents = ContentObjectStore::ContentBlock::Document.all
  end

  def show
    @content_block_document = ContentObjectStore::ContentBlock::Document.find(params[:id])
    @content_block_versions = @content_block_document.versions

    @host_content_items = ContentObjectStore::GetHostContentItems.by_embedded_document(
      content_block_document: @content_block_document,
    )
  end

  def new
    if params[:block_type].blank?
      @schemas = ContentObjectStore::ContentBlock::Schema.all
    else
      @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(params[:block_type].underscore)
      @form = ContentObjectStore::ContentBlock::DocumentForm.new(schema: @schema)
    end
  end

  def create
    @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(params[:block_type].underscore)
    new_edition = ContentObjectStore::CreateEditionService.new(@schema).call(edition_params)
    redirect_to content_object_store.review_content_object_store_content_block_edition_path(new_edition)
  rescue ActiveRecord::RecordInvalid => e
    @form = ContentObjectStore::ContentBlock::DocumentForm.new(content_block_edition: e.record, schema: @schema)
    render "content_object_store/content_block/documents/new"
  end

  def new_document_options_redirect
    if params[:block_type].present?
      redirect_to content_object_store.new_content_object_store_content_block_document_path(block_type: params.require(:block_type))
    else
      redirect_to content_object_store.new_content_object_store_content_block_document_path, flash: { error: "You must select a block type" }
    end
  end
end
