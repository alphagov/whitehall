# Trying to figure out how configurable document types work? Check the documentation: `docs/configurable_document_types.md`!
class Admin::StandardEditionsController < Admin::EditionsController
  prepend_before_action :prevent_access_when_disabled

  rescue_from ConfigurableDocumentType::NotFoundError, with: :render_not_found

  def choose_type
    @permitted_configurable_document_types = ConfigurableDocumentType.where_group(params[:group])
                                                                     .select { |type| can?(current_user, type) }

    render_not_found if @permitted_configurable_document_types.empty?
  end

private

  def edition_class
    StandardEdition
  end

  def prevent_access_when_disabled
    render_not_found unless Flipflop.configurable_document_types?
  end

  def new_edition_params
    # Set the configurable document type for new editions based on the value from the query parameter submitted with the 'choose_type' form
    super[:configurable_document_type].blank? ? super.merge(configurable_document_type: params[:configurable_document_type]) : super
  end

  def render_not_found
    render "admin/errors/not_found", status: :not_found
  end
end
