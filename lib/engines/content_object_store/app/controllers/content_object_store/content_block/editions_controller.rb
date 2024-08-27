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

  def update
    content_block_edition = ContentObjectStore::ContentBlock::Edition.find(params[:id])
    @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(content_block_edition.document.block_type)

    new_edition = edition_params
    if params[:schedule_publishing] == "schedule"
      new_edition = edition_params.merge!(scheduled_publication_params)
      new_content_block_edition = ContentObjectStore::ScheduleEditionService.new(
        content_block_edition,
      ).call(new_edition)
      flash_text = "#{@schema.name} scheduled successfully"
    else
      new_content_block_edition = ContentObjectStore::UpdateEditionService.new(
        @schema,
        content_block_edition,
      ).call(new_edition)
      flash_text = "#{@schema.name} changed and published successfully"
    end

    redirect_to content_object_store.content_object_store_content_block_document_path(new_content_block_edition.document),
                flash: { notice: flash_text }
  rescue ActiveRecord::RecordInvalid => e
    @form = ContentObjectStore::ContentBlock::EditionForm::Update.new(
      content_block_edition: e.record, schema: @schema,
      edition_to_update_id: content_block_edition.id
    )

    render :edit
  end

private

  def root_params
    params.require(:content_object_store_content_block_edition)
  end

  def edition_params
    params.require(:content_block_edition)
      .permit(
        :organisation_id,
        :creator,
        "scheduled_publication(1i)",
        "scheduled_publication(2i)",
        "scheduled_publication(3i)",
        "scheduled_publication(4i)",
        "scheduled_publication(5i)",
        document_attributes: %w[title block_type],
        details: @schema.fields,
      )
      .merge!(creator: current_user)
  end

  def block_type_param
    params.require(:content_block_edition).require("document_attributes").require(:block_type)
  end

  def scheduled_publication_params
    params.require(:scheduled_at).permit("scheduled_publication(1i)",
                                         "scheduled_publication(2i)",
                                         "scheduled_publication(3i)",
                                         "scheduled_publication(4i)",
                                         "scheduled_publication(5i)")
  end
end
