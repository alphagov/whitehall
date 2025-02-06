class ContentBlockManager::ContentBlock::Documents::EmbeddedObjectsController < ContentBlockManager::BaseController
  before_action :initialize_document_and_schema

  def new
    @content_block_edition = @content_block_document.latest_edition
  end

  def create
    @content_block_edition = @content_block_document.latest_edition.clone_edition(creator: current_user)
    @params = object_params.dig(:details, @subschema.block_type)
    @content_block_edition.add_object_to_details(@subschema.block_type, @params)
    @content_block_edition.save!

    ContentBlockManager::PublishEditionService.new.call(@content_block_edition)
    flash[:notice] = "#{@subschema.name.singularize} created"
    redirect_to content_block_manager.content_block_manager_content_block_document_path(@content_block_document)
  rescue ActiveRecord::RecordInvalid
    render :new
  end

private

  def initialize_document_and_schema
    @content_block_document = ContentBlockManager::ContentBlock::Document.find(params[:document_id])
    @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_document.block_type)
    @subschema = @schema.subschema(params[:object_type])

    render "admin/errors/not_found", status: :not_found unless @subschema
  end

  def object_params
    params.require("content_block/edition").permit(
      details: {
        @subschema.block_type.to_s => @subschema.permitted_params,
      },
    )
  end
end
