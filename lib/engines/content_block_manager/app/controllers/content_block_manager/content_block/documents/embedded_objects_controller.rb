class ContentBlockManager::ContentBlock::Documents::EmbeddedObjectsController < ContentBlockManager::BaseController
  include EmbeddedObjects

  before_action :initialize_document

  def new
    @content_block_edition = @content_block_document.latest_edition
    if @subschema
      render :new
    else
      @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_document.block_type)
      @group = params[:group]
      @subschemas = @schema.subschemas_for_group(@group)

      if @subschemas.blank?
        render "admin/errors/not_found", status: :not_found
      else
        render :select_subschema
      end
    end
  end

  def create
    initialize_schemas
    @content_block_edition = @content_block_document.latest_edition.clone_edition(creator: current_user)
    @params = object_params(@subschema).dig(:details, @subschema.block_type)
    @content_block_edition.add_object_to_details(@subschema.block_type, @params)
    @content_block_edition.save!

    redirect_to content_block_manager.review_embedded_object_content_block_manager_content_block_edition_path(
      @content_block_edition,
      object_type: @subschema.block_type,
      object_title: @content_block_edition.key_for_object(@params),
    )
  rescue ActiveRecord::RecordInvalid
    render :new
  end

  def new_embedded_objects_options_redirect
    @content_block_document = ContentBlockManager::ContentBlock::Document.find(params[:document_id])

    if params[:object_type].present?
      redirect_to content_block_manager.new_content_block_manager_content_block_document_embedded_object_path(@content_block_document, object_type: params.require(:object_type))
    else
      redirect_to content_block_manager.new_content_block_manager_content_block_document_embedded_object_path(@content_block_document, group: params.require(:group)), flash: { error: I18n.t("activerecord.errors.models.content_block_manager/content_block/document.attributes.block_type.blank") }
    end
  end

private

  def initialize_document
    @content_block_document = ContentBlockManager::ContentBlock::Document.find(params[:document_id])
  end

  def initialize_schemas
    get_schema_and_subschema(@content_block_document.block_type, params[:object_type])
    unless @subschema
      render "admin/errors/not_found", status: :not_found and return
    end
  end
end
