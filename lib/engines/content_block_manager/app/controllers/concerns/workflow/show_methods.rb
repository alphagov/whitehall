module Workflow::ShowMethods
  extend ActiveSupport::Concern

  def edit_draft
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
    @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)
    @form = ContentBlockManager::ContentBlock::EditionForm::Edit.new(content_block_edition: @content_block_edition, schema: @schema)

    @title = @content_block_edition.document.is_new_block? ? "Create #{@form.schema.name}" : "Change #{@form.schema.name}"
    @back_path = @content_block_edition.document.is_new_block? ? content_block_manager.new_content_block_manager_content_block_document_path : @form.back_path

    render :edit_draft
  end

  # This handles the optional embedded objects in the flow, delegating to `embedded_objects`
  def method_missing(method_name, *arguments, &block)
    if method_name.to_s =~ /#{Workflow::Step::SUBSCHEMA_PREFIX}(.*)/
      embedded_objects(::Regexp.last_match(1))
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?(Workflow::Step::SUBSCHEMA_PREFIX) || super
  end

  def review_links
    @content_block_document = @content_block_edition.document
    @order = params[:order]
    @page = params[:page]

    @host_content_items = ContentBlockManager::HostContentItem.for_document(
      @content_block_document,
      order: @order,
      page: @page,
    )

    render :review_links
  end

  def schedule_publishing
    @content_block_document = @content_block_edition.document

    render :schedule_publishing
  end

  def internal_note
    @content_block_document = @content_block_edition.document

    render :internal_note
  end

  def change_note
    @content_block_document = @content_block_edition.document

    render :change_note
  end

  def review
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])

    render :review
  end

  def confirmation
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])

    @confirmation_copy = ContentBlockManager::ConfirmationCopyPresenter.new(@content_block_edition)

    render :confirmation
  end

  def back_path
    content_block_manager.content_block_manager_content_block_workflow_path(
      @content_block_edition,
      step: previous_step.name,
    )
  end
  included do
    helper_method :back_path
  end

private

  def embedded_objects(subschema_name)
    @subschema = @schema.subschema(subschema_name)
    @step_name = current_step.name
    @action = @content_block_edition.document.is_new_block? ? "Add" : "Edit"
    @add_button_text = has_embedded_objects ? "Add another #{subschema_name.humanize.singularize.downcase}" : "Add a #{@subschema.name.humanize.singularize.downcase}"

    if @subschema
      render :embedded_objects
    else
      raise ActionController::RoutingError, "Subschema #{subschema_name} does not exist"
    end
  end

  def has_embedded_objects
    @content_block_edition.details[@subschema.block_type].present?
  end
end
