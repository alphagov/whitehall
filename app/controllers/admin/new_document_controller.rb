class Admin::NewDocumentController < Admin::BaseController
  include DocumentTypesConcern

  def index
    @document_types = standard_document_types
    @requires_approval_document_types = requires_approval_document_types
    @parent_edition = parent_edition
    @no_child_document_types = no_child_document_types?
  end

  def new_document_options_redirect
    new_document_type_key = params[:new_document_options]
    return redirect_to admin_new_document_path, alert: "Please select a new document option" if new_document_type_key.blank?

    document_type = permitted_document_types[new_document_type_key]
    return render "admin/errors/not_found", status: :not_found unless document_type

    redirect = document_type_redirect(document_type) || send("new_admin_#{new_document_type_key}_path")

    redirect_to include_parent_edition_id_in_redirect(redirect)
  end

private

  def parent_edition
    StandardEdition.find_by(id: params[:parent_edition_id]) if params[:parent_edition_id].present?
  end

  def no_child_document_types?
    params[:parent_edition_id].present? && permitted_document_types.empty?
  end

  def include_parent_edition_id_in_redirect(redirect)
    if params[:parent_edition_id].present?
      uri = URI.parse(redirect)
      query_params = Rack::Utils.parse_nested_query(uri.query)
      query_params["parent_edition_id"] = params[:parent_edition_id]
      uri.query = query_params.to_query
      uri.to_s
    else
      redirect
    end
  end
end
