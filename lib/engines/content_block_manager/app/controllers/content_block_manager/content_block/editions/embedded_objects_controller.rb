class ContentBlockManager::ContentBlock::Editions::EmbeddedObjectsController < ContentBlockManager::BaseController
  include EmbeddedObjects

  before_action :initialize_edition_and_schema

  def edit
    @object_name = params[:object_name]
    @object = @content_block_edition.details.dig(params[:object_type], params[:object_name])

    render "admin/errors/not_found", status: :not_found unless @object
  end

  def update
    @object = object_params(@subschema).dig(:details, @subschema.block_type)
    @content_block_edition.update_object_with_details(params[:object_type], params[:object_name], @object)
    @content_block_edition.save!

    flash[:notice] = "#{@subschema.name.singularize} updated"
    redirect_to content_block_manager.content_block_manager_content_block_document_path(@content_block_edition.document)
  rescue ActiveRecord::RecordInvalid
    @object_name = params[:object_name]
    render :edit
  end

  def review
    @object_name = params[:object_name]
  end

  def publish
    if params[:is_confirmed].blank?
      flash[:error] = I18n.t("content_block_edition.review_page.errors.confirm")
      redirect_path = content_block_manager.review_embedded_object_content_block_manager_content_block_edition_path(
        @content_block_edition,
        object_type: @subschema.block_type,
        object_name: params[:object_name],
      )
    else
      ContentBlockManager::PublishEditionService.new.call(@content_block_edition)
      flash[:notice] = "#{@subschema.name.singularize} created"
      redirect_path = content_block_manager.content_block_manager_content_block_document_path(@content_block_edition.document)
    end

    redirect_to redirect_path
  end

private

  def initialize_edition_and_schema
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
    get_schema_and_subschema(@content_block_edition.document.block_type, params[:object_type])
  end
end
