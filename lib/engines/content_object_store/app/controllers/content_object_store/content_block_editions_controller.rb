class ContentObjectStore::ContentBlockEditionsController < Admin::BaseController
  def index
    @content_block_editions = ContentObjectStore::ContentBlockEdition.all
  end

  def show
    @content_block_edition = ContentObjectStore::ContentBlockEdition.find(params[:id])
  end

  def new
    if params[:block_type].blank?
      @schemas = ContentObjectStore::ContentBlockSchema.all
    else
      @schema = ContentObjectStore::ContentBlockSchema.find_by_block_type(params[:block_type].underscore)
      @content_block_edition = ContentObjectStore::ContentBlockEdition.new(block_type: @schema.block_type)
    end
  end

  def create
    @schema = ContentObjectStore::ContentBlockSchema.find_by_block_type(root_params[:block_type])

    ContentObjectStore::CreateEditionService.new(@schema, new_edition_params).call

    redirect_to content_object_store.content_object_store_content_block_editions_path, flash: { notice: "#{@schema.name} created successfully" }
  end

  def edit
    @content_block_edition = ContentObjectStore::ContentBlockEdition.find(params[:id])
    @schema = ContentObjectStore::ContentBlockSchema.find_by_block_type(@content_block_edition.document.block_type)
  end

  def update
    @content_block_edition = ContentObjectStore::ContentBlockEdition.find(params[:id])
    @schema = ContentObjectStore::ContentBlockSchema.find_by_block_type(@content_block_edition.document.block_type)

    result = ContentObjectStore::UpdateEditionService.new(@content_block_edition).
      call(edit_params[:document_title], edit_params[:details])

    redirect_to content_object_store.content_object_store_content_block_edition_path(@content_block_edition), flash: { notice: "#{@schema.name} changed successfully" }
  end

private

  def root_params
    params.require(:content_object_store_content_block_edition)
  end

  def new_edition_params
    root_params.permit(:document_title, :block_type, details: @schema.fields)
  end

  def edit_params
    root_params.permit(:document_title, details: @schema.fields)
  end
end
