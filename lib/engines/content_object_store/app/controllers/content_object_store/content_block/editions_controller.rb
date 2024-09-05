class ContentObjectStore::ContentBlock::EditionsController < ContentObjectStore::BaseController
  def new
    if params[:block_type].blank?
      @error_message = "You must select a block type" if params[:block_type] == ""
      @schemas = ContentObjectStore::ContentBlock::Schema.all
    else
      @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(params[:block_type].underscore)
      @form = ContentObjectStore::ContentBlock::EditionForm::Create.new(
        content_block_edition: ContentObjectStore::ContentBlock::Edition.new,
        schema: @schema,
      )
    end
  end

  def create
    @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(block_type_param)

    new_edition = ContentObjectStore::CreateEditionService.new(@schema).call(edition_params)

    redirect_to content_object_store.review_content_object_store_content_block_edition_path(new_edition)
  rescue ActiveRecord::RecordInvalid => e
    @form = ContentObjectStore::ContentBlock::EditionForm::Create.new(content_block_edition: e.record, schema: @schema)
    render :new
  end

  def review
    @content_block_edition = ContentObjectStore::ContentBlock::Edition.find(params[:id])
  end

  EDIT_FORM_STEPS = {
    edit_block: "edit_block",
    review_links: "review_links",
    schedule_publishing: "schedule_publishing",
  }.freeze

  def edit
    step = params[:step]
    @content_block_edition = ContentObjectStore::ContentBlock::Edition.find(params[:id])
    @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)

    case step
    when EDIT_FORM_STEPS[:edit_block]
      edit_block
    when EDIT_FORM_STEPS[:review_links]
      review_links
    when EDIT_FORM_STEPS[:schedule_publishing]
      schedule_publishing
    end
  end

  def edit_block
    @form = ContentObjectStore::ContentBlock::EditionForm::Update.new(
      content_block_edition: @content_block_edition, schema: @schema, edition_to_update_id: @content_block_edition.id,
    )
  end

  def review_links
    @content_block_document = @content_block_edition.document
    @edition_params = edition_params

    new_edition = ContentObjectStore::ContentBlock::Edition.new(edition_params)
    new_edition.document.id = @content_block_document.id

    if new_edition.valid?
      @host_content_items = ContentObjectStore::GetHostContentItems.by_embedded_document(
        content_block_document: @content_block_document,
      )

      render :review_links
    else
      @form = ContentObjectStore::ContentBlock::EditionForm::Update.new(
        content_block_edition: new_edition,
        schema: @schema, edition_to_update_id: @content_block_edition.id
      )

      render :edit
    end
  end

  def schedule_publishing
    @content_block_document = @content_block_edition.document
    @edition_params = edition_params

    render :schedule_publishing
  end

private

  def root_params
    params.require(:content_object_store_content_block_edition)
  end

  def block_type_param
    params.require("content_block/edition").require("document_attributes").require(:block_type)
  end
end
