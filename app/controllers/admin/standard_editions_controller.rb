# Trying to figure out how configurable document types work? Check the documentation: `docs/configurable_document_types.md`!
class Admin::StandardEditionsController < Admin::EditionsController
  prepend_before_action :prevent_access_when_disabled

  rescue_from ConfigurableDocumentType::NotFoundError, with: :render_not_found

  def choose_type
    selected_key = params[:configurable_document_type].presence

    if !selected_key
      # Initial page: top-level types and groups
      groups = ConfigurableDocumentType.groups.map do |group_id|
        # No `can?` check for groups, as the permissions are defined per-type.
        # The `can?` check happens on each sub-type when rendering the interstitial step.
        OpenStruct.new({
          key: group_id,
          label: group_id.humanize,
          description: "This is a 'group'. You will see options for this group on the next screen.",
        })
      end
      @permitted_configurable_document_types =
        groups + ConfigurableDocumentType.top_level.select { |t| can?(current_user, t) }
    elsif ConfigurableDocumentType.groups.include?(selected_key)
      # Interstitial step: show subtypes for the selected parent
      children = ConfigurableDocumentType.children_for(selected_key)
      @permitted_configurable_document_types = children.select { |t| can?(current_user, t) }
    elsif ConfigurableDocumentType.find(selected_key)
      # Leaf: go to new
      redirect_to new_admin_standard_edition_path(configurable_document_type: selected_key)
    end
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
