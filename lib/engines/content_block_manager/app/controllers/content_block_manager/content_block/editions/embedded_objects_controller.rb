class ContentBlockManager::ContentBlock::Editions::EmbeddedObjectsController < ContentBlockManager::BaseController
  include EmbeddedObjects

  before_action :initialize_edition

  def new
    @schema = get_schema(@content_block_edition.document.block_type)

    if params[:object_type]
      @subschema = get_subschema(@schema, params[:object_type])
      @back_link = embedded_objects_path

      render :new
    else
      @group = params[:group]
      @subschemas = @schema.subschemas_for_group(@group)
      @back_link = content_block_manager.content_block_manager_content_block_workflow_path(
        @content_block_edition,
        step: "#{Workflow::Step::GROUP_PREFIX}#{@group}",
      )
      @redirect_path = content_block_manager.new_embedded_objects_options_redirect_content_block_manager_content_block_edition_path(@content_block_edition)
      @context = @content_block_edition.title

      if @subschemas.blank?
        render "admin/errors/not_found", status: :not_found
      else
        render "content_block_manager/content_block/shared/embedded_objects/select_subschema"
      end
    end
  end

  def create
    @schema, @subschema = get_schema_and_subschema(@content_block_edition.document.block_type, params[:object_type])
    @object = object_params(@subschema).dig(:details, @subschema.block_type)
    @content_block_edition.add_object_to_details(@subschema.block_type, @object)
    @content_block_edition.save!

    flash[:notice] = I18n.t(
      "content_block_edition.create.embedded_objects.added_confirmation",
      name_capitalized: @subschema.name.singularize,
      name_downcase: @subschema.name.singularize.downcase,
      schema_name: @schema.name.singularize.downcase,
    )
    redirect_to embedded_objects_path
  rescue ActiveRecord::RecordInvalid
    @back_link = embedded_objects_path
    render :new
  end

  def edit
    @schema, @subschema = get_schema_and_subschema(@content_block_edition.document.block_type, params[:object_type])
    @redirect_url = params[:redirect_url]
    @object_title = params[:object_title]
    @object = @content_block_edition.details.dig(params[:object_type], params[:object_title])

    render "admin/errors/not_found", status: :not_found unless @object
  end

  def update
    @schema, @subschema = get_schema_and_subschema(@content_block_edition.document.block_type, params[:object_type])
    @object = object_params(@subschema).dig(:details, @subschema.block_type)
    @content_block_edition.update_object_with_details(params[:object_type], params[:object_title], @object)
    @content_block_edition.save!

    if params[:redirect_url].present?
      flash[:notice] = I18n.t(
        "content_block_edition.create.embedded_objects.edited_confirmation",
        name_capitalized: @subschema.name.singularize,
        name_downcase: @subschema.name.singularize.downcase,
        schema_name: @schema.name.singularize.downcase,
      )
      redirect_to params[:redirect_url], allow_other_host: false
    else
      redirect_to content_block_manager.review_embedded_object_content_block_manager_content_block_edition_path(
        @content_block_edition,
        object_type: @subschema.block_type,
        object_title: params[:object_title],
      )
    end
  rescue ActiveRecord::RecordInvalid
    @redirect_url = params[:redirect_url]
    @object_title = params[:object_title]
    render :edit
  end

  def review
    @schema, @subschema = get_schema_and_subschema(@content_block_edition.document.block_type, params[:object_type])
    @object_title = params[:object_title]
  end

  def publish
    @schema, @subschema = get_schema_and_subschema(@content_block_edition.document.block_type, params[:object_type])
    if params[:is_confirmed].blank?
      flash[:error] = I18n.t("content_block_edition.review_page.errors.confirm")
      redirect_path = content_block_manager.review_embedded_object_content_block_manager_content_block_edition_path(
        @content_block_edition,
        object_type: @subschema.block_type,
        object_title: params[:object_title],
      )
    else
      @content_block_edition.updated_embedded_object_type = @subschema.block_type
      @content_block_edition.updated_embedded_object_title = params[:object_title]
      ContentBlockManager::PublishEditionService.new.call(@content_block_edition)
      flash[:notice] = "#{@subschema.name.singularize} created"
      redirect_path = content_block_manager.content_block_manager_content_block_document_path(@content_block_edition.document)
    end

    redirect_to redirect_path
  end

  def new_embedded_objects_options_redirect
    if params[:object_type].present?
      flash[:back_link] = content_block_manager.new_embedded_objects_options_redirect_content_block_manager_content_block_edition_path(
        @content_block_edition,
        group: params.require(:group),
      )
      redirect_to content_block_manager.new_embedded_object_content_block_manager_content_block_edition_path(@content_block_edition, object_type: params.require(:object_type))
    else
      redirect_to content_block_manager.new_embedded_object_content_block_manager_content_block_edition_path(@content_block_edition, group: params.require(:group)), flash: { error: I18n.t("activerecord.errors.models.content_block_manager/content_block/document.attributes.block_type.blank") }
    end
  end

private

  def initialize_edition
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
  end

  def embedded_objects_path
    step = @subschema.group ? "#{Workflow::Step::GROUP_PREFIX}#{@subschema.group}" : "#{Workflow::Step::SUBSCHEMA_PREFIX}#{@subschema.id}"
    content_block_manager.content_block_manager_content_block_workflow_path(@content_block_edition, step:)
  end
end
