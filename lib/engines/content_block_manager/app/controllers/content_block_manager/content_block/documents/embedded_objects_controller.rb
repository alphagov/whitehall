class ContentBlockManager::ContentBlock::Documents::EmbeddedObjectsController < ContentBlockManager::BaseController
  include EmbeddedObjects

  before_action :initialize_document_and_schema

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

private

  def initialize_document_and_schema
    @content_block_document = ContentBlockManager::ContentBlock::Document.find(params[:document_id])
    if params[:object_type]
      get_schema_and_subschema(@content_block_document.block_type, params[:object_type])
      render "admin/errors/not_found", status: :not_found unless @subschema
    end
  end
end
