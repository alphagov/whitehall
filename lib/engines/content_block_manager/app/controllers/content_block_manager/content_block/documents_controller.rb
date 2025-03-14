class ContentBlockManager::ContentBlock::DocumentsController < ContentBlockManager::BaseController
  def index
    if params_filters.any?
      @filters = params_filters
      filter_result = ContentBlockManager::ContentBlock::Document::DocumentFilter.new(@filters)
      @content_block_documents = filter_result.paginated_documents
      unless filter_result.valid?
        @errors = filter_result.errors
        @error_summary_errors = @errors.map { |error| { text: error.full_message, href: "##{error.attribute}_3i" } }
      end
      render :index
    else
      redirect_to content_block_manager.content_block_manager_root_path(default_filters)
    end
  end

  def show
    @content_block_document = ContentBlockManager::ContentBlock::Document.find(params[:id])
    @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_document.block_type)
    @content_block_versions = @content_block_document.versions
    @order = params[:order]
    @page = params[:page]

    @host_content_items = ContentBlockManager::HostContentItem.for_document(
      @content_block_document,
      order: @order,
      page: @page,
    )
  end

  def content_id
    content_block_document = ContentBlockManager::ContentBlock::Document.where(content_id: params[:content_id]).first

    if content_block_document.present?
      redirect_to content_block_manager.content_block_manager_content_block_document_path(content_block_document)
    else
      raise ActiveRecord::RecordNotFound, "Could not find Content Block with Content ID #{params[:content_id]}"
    end
  end

  def new
    @schemas = ContentBlockManager::ContentBlock::Schema.all
  end

  def new_document_options_redirect
    if params[:block_type].present?
      redirect_to content_block_manager.new_content_block_manager_content_block_edition_path(block_type: params.require(:block_type))
    else
      redirect_to content_block_manager.new_content_block_manager_content_block_document_path, flash: { error: I18n.t("activerecord.errors.models.content_block_manager/content_block/document.attributes.block_type.blank") }
    end
  end

private

  def params_filters
    params.slice(:keyword, :block_type, :lead_organisation, :page, :last_updated_to, :last_updated_from)
          .permit!
          .to_h
  end

  def default_filters
    { lead_organisation: "" }
  end
end
