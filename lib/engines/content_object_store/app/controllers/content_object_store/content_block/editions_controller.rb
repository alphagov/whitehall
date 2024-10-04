class ContentObjectStore::ContentBlock::EditionsController < ContentObjectStore::BaseController
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
  def new
    @content_block_document = ContentObjectStore::ContentBlock::Document.find(params[:document_id])
    @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(@content_block_document.block_type)
    @form = ContentObjectStore::ContentBlock::EditionForm.new(
      content_block_edition: @content_block_document.latest_edition,
      schema: @schema,
    )
  end

  def review_links
    @content_block_document = @content_block_edition.document
    @edition_params = edition_params

  def create
    @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(block_type_param)
    new_edition = ContentObjectStore::ContentBlock::Edition.new(edition_params)
    new_edition.document_id = params[:document_id]
    new_edition.document.assign_attributes(edition_params[:document_attributes].except(:block_type))

    if new_edition.valid? && new_edition.document.valid?
      new_edition.save!
      new_edition.document.save!
      redirect_to content_object_store.content_object_store_content_block_step_path(id: new_edition.id, step: "review_links")
    else
      @form = ContentObjectStore::ContentBlock::EditionForm.new(content_block_edition: new_edition, schema: @schema)
      render "content_object_store/content_block/documents/new"
    end
  end

  def schedule_publishing
    @content_block_document = @content_block_edition.document
    @edition_params = edition_params

    render :schedule_publishing
  def review
    @content_block_edition = ContentObjectStore::ContentBlock::Edition.find(params[:id])
  end

private

  def block_type_param
    params.require("content_block/edition").require("document_attributes").require(:block_type)
  end
end
