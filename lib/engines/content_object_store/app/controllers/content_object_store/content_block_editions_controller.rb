class ContentObjectStore::ContentBlockEditionsController < Admin::BaseController
  def index
    @content_block_editions = ContentObjectStore::ContentBlockEdition.all
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
    @content_block_edition = ContentObjectStore::ContentBlockEdition.create!(edition_params)

    result = Services.publishing_api.put_content(@content_block_edition.document.content_id, {
      schema_name: @schema.id,
      document_type: @schema.id,
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      title: edition_params[:document_title],
      details: edition_params[:details].to_h,
    })

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
