class ContentBlockManager::ContentBlock::DocumentsController < ContentBlockManager::BaseController
  def index
    if params_filters.any?
      session[:content_block_filters] = params_filters
      @filters = params_filters
      filter_result = ContentBlockManager::ContentBlock::Document::DocumentFilter.new(@filters)
      @content_block_documents = filter_result.paginated_documents
      unless filter_result.valid?
        @errors = filter_result.errors
        @error_summary_errors = @errors.map { |error| { text: error.full_message, href: "##{error.attribute}_3i" } }
      end
      render :index
    elsif params[:reset_fields].blank? && session_filters.any?
      redirect_to content_block_manager.content_block_manager_root_path(session_filters)
    else
      redirect_to content_block_manager.content_block_manager_root_path(default_filters)
    end
  end

  def show
    @content_block_document = ContentBlockManager::ContentBlock::Document.find(params[:id])
    @content_block_versions = @content_block_document.versions
    @order = params[:order]
    @page = params[:page]

    @host_content_items = ContentBlockManager::GetHostContentItems.by_embedded_document(
      content_block_document: @content_block_document,
      order: @order,
      page: @page,
    )
  end

  def new
    @schemas = ContentBlockManager::ContentBlock::Schema.all
  end

  def new_document_options_redirect
    if params[:block_type].present?
      redirect_to content_block_manager.new_content_block_manager_content_block_edition_path(block_type: params.require(:block_type))
    else
      redirect_to content_block_manager.new_content_block_manager_content_block_document_path, flash: { error: "You must select a block type" }
    end
  end

private

  def params_filters
    params.slice(:keyword, :block_type, :lead_organisation, :page, :last_updated_to, :last_updated_from)
          .permit!
          .to_h
  end

  def session_filters
    (session[:content_block_filters] || {}).to_h
  end

  def default_filters
    { lead_organisation: "" }
  end
end
