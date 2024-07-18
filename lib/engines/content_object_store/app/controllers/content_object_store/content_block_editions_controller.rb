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
      @content_block_edition = ContentObjectStore::ContentBlockEdition.new
    end
  end

  def create
    @schema = ContentObjectStore::ContentBlockSchema.find_by_block_type(block_type_param)

    ContentObjectStore::CreateEditionService.new(@schema).call(edition_params)

    redirect_to content_object_store.content_object_store_content_block_editions_path, flash: { notice: "#{@schema.name} created successfully" }
  rescue ActiveRecord::RecordInvalid => e
    @content_block_edition = e.record
    render :new
  end

private

  def root_params
    params.require(:content_object_store_content_block_edition)
  end

  def edition_params
    params.require(:content_block_edition)
      .permit(content_block_document_attributes: %w[title block_type], details: @schema.fields)
      .merge(creator: current_user)
  end

  def block_type_param
    params.require(:content_block_edition).require("content_block_document_attributes").require(:block_type)
  end
end
