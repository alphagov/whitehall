class ContentObjectStore::ContentBlockEditionsController < Admin::BaseController
  def index
    @content_block_editions = ContentObjectStore::ContentBlockEdition.all
  end

  def new
    if params[:block_type].blank?
      @schemas = ContentObjectStore::SchemaService.valid_schemas
    end
  end
end
