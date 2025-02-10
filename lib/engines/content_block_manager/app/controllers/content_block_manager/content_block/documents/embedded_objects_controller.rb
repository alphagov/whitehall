class ContentBlockManager::ContentBlock::Documents::EmbeddedObjectsController < ContentBlockManager::BaseController
  include EmbeddedObjects

  before_action :initialize_document_and_schema

  def new
    @content_block_edition = @content_block_document.latest_edition
  end

  def create
    @content_block_edition = @content_block_document.latest_edition.clone_edition(creator: current_user)
    @params = object_params(@subschema).dig(:details, @subschema.block_type)
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
    get_schema_and_subschema(@content_block_document.block_type, params[:object_type])

    render "admin/errors/not_found", status: :not_found unless @subschema
  end
end
