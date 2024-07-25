class ContentObjectStore::ContentBlockEditionsController < ContentObjectStore::BaseController
  def new
    if params[:block_type].blank?
      @schemas = ContentObjectStore::ContentBlock::Schema.all
    else
      @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(params[:block_type].underscore)
      @form = ContentObjectStore::ContentBlockEditionForm::Create.new(
        content_block_edition: ContentObjectStore::ContentBlock::Edition.new,
        schema: @schema,
      )
    end
  end

  def create
    @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(block_type_param)

    new_edition = ContentObjectStore::CreateEditionService.new(@schema).call(edition_params)

    redirect_to content_object_store.content_object_store_content_block_document_path(new_edition.document), flash: { notice: "#{@schema.name} created successfully" }
  rescue ActiveRecord::RecordInvalid => e
    @form = ContentObjectStore::ContentBlockEditionForm::Create.new(content_block_edition: e.record, schema: @schema)
    render :new
  end

  def edit
    content_block_edition = ContentObjectStore::ContentBlock::Edition.find(params[:id])
    @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(content_block_edition.document.block_type)

    @form = ContentObjectStore::ContentBlockEditionForm::Update.new(content_block_edition:, schema: @schema)
  end

  def update
    content_block_edition = ContentObjectStore::ContentBlock::Edition.find(params[:id])
    @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(content_block_edition.document.block_type)

    new_content_block_edition = ContentObjectStore::UpdateEditionService.new(
      @schema,
      content_block_edition,
    ).call(edition_params)

    redirect_to content_object_store.content_object_store_content_block_document_path(new_content_block_edition.document),
                flash: { notice: "#{@schema.name} changed and published successfully" }
  rescue ActiveRecord::RecordInvalid => e
    @form = ContentObjectStore::ContentBlockEditionForm::Update.new(content_block_edition: e.record, schema: @schema)

    render :edit
  end

private

  def root_params
    params.require(:content_object_store_content_block_edition)
  end

  def edition_params
    params.require(:content_block_edition)
      .permit(document_attributes: %w[title block_type], details: @schema.fields)
      .merge(creator: current_user)
  end

  def block_type_param
    params.require(:content_block_edition).require("document_attributes").require(:block_type)
  end
end
