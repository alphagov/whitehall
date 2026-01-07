# Trying to figure out how configurable document types work? Check the documentation: `docs/configurable_document_types.md`!
class Admin::StandardEditionsController < Admin::EditionsController
  rescue_from ConfigurableDocumentType::NotFoundError, with: :render_not_found

  def choose_type
    @permitted_configurable_document_types = ConfigurableDocumentType.where_group(params[:group])
                                                                     .select { |type| can?(current_user, type) }

    render_not_found if @permitted_configurable_document_types.empty?
  end

  def change_type
    find_edition
    limit_edition_access!

    @available_types = ConfigurableDocumentType.convertible_from(@edition.configurable_document_type)
      .select { |type| can?(current_user, type) }
  end

  def change_type_preview
    find_edition
    limit_edition_access!
    detect_other_active_editors

    new_type_id = params.fetch(:configurable_document_type)
    @old_type = ConfigurableDocumentType.find(@edition.configurable_document_type)
    @new_type = ConfigurableDocumentType.find(new_type_id)
  end

  def apply_change_type
    find_edition
    limit_edition_access!

    new_type_id = params.fetch(:configurable_document_type)
    @old_type = ConfigurableDocumentType.find(@edition.configurable_document_type)
    @new_type = ConfigurableDocumentType.find(new_type_id)

    conversion = ConfigurableDocumentType::Conversion.new(@old_type, @new_type)

    if conversion.convert(@edition)
      redirect_to admin_standard_edition_path(@edition), notice: "Document type changed successfully."
    else
      redirect_to change_type_preview_admin_standard_edition_path(@edition, configurable_document_type: new_type_id), alert: "Could not change document type."
    end
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
