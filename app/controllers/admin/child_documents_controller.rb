class Admin::ChildDocumentsController < Admin::EditionsController
  rescue_from ConfigurableDocumentType::NotFoundError, with: :render_not_found

  def choose_type
    @permitted_child_document_types = ConfigurableDocumentType.child_document_types_of(StandardEdition.find(params[:parent_edition_id])).select { |type| can?(current_user, type) }

    render_not_found if @permitted_child_document_types.empty?
  end

private

  def edition_class
    StandardEdition
  end

  def new_edition_params
    # Set the configurable document type for new editions based on the value from the query parameter submitted with the 'choose_type' form
    super[:configurable_document_type].blank? ? super.merge(configurable_document_type: params[:configurable_document_type]) : super
  end

  def render_not_found
    render "admin/errors/not_found", status: :not_found
  end
end
