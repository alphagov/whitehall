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

    ContentObjectStore::CreateEditionService.new(@schema, edition_params).call

    redirect_to content_object_store.content_object_store_content_block_editions_path, flash: { notice: "#{@schema.name} created successfully" }
  end

private

  def root_params
    params.require(:content_object_store_content_block_edition)
  end

  def edition_params
    root_params.permit(:document_title, :block_type, details: @schema.fields)
  end
end
