# Trying to figure out how configurable document types work? Check the documentation: `docs/configurable_document_types.md`!
class Admin::StandardEditionsController < Admin::EditionsController
  prepend_before_action :prevent_access_when_disabled
  def choose_type
    @permitted_configurable_document_types = ConfigurableDocumentType.all.select { |type| can?(current_user, type) }
  end

private

  def edition_class
    StandardEdition
  end

  def prevent_access_when_disabled
    head :not_found unless Flipflop.configurable_document_types?
  end

  def new_edition_params
    # Set the configurable document type for new editions based on the value from the query parameter submitted with the 'choose_type' form
    super[:configurable_document_type].blank? ? super.merge(configurable_document_type: params[:configurable_document_type]) : super
  end
end
