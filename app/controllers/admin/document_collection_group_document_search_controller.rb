class Admin::DocumentCollectionGroupDocumentSearchController < Admin::BaseController
  before_action :load_document_collection
  before_action :load_document_collection_group
  before_action :check_new_design_system_permissions
  layout :get_layout

  def search_options; end

  def search
    redirect_to(action: :search_title_slug, document_collection_id: @collection, group_id: @group) if params[:search_option] == "title-or-slug"
  end

  def search_title_slug; end

private

  def check_new_design_system_permissions
    forbidden! unless new_design_system?
  end

  def get_layout
    preview_design_system?(next_release: false) ? "design_system" : "admin"
  end

  def load_document_collection
    @collection = DocumentCollection.includes(document: :latest_edition).find(params[:document_collection_id])
  end

  def load_document_collection_group
    @group = @collection.groups.find(params[:group_id])
    session[:document_collection_selected_group_id] = params[:group_id]
  end
end
