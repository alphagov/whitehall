class Admin::DocumentCollectionGroupDocumentSearchController < Admin::BaseController
  before_action :load_document_collection
  before_action :load_document_collection_group
  before_action :check_new_design_system_permissions
  layout :get_layout

  def search_options; end

  def search
    case params[:search_option]
    when "title-or-slug"
      redirect_to(action: :search_title_slug, document_collection_id: @collection, group_id: @group)
    when "url"
      redirect_to(action: :add_by_url, document_collection_id: @collection, group_id: @group)
    else
      flash.now[:alert] = "Please select a search option"
      render :search_options
    end
  end

  def search_title_slug
    flash.now[:alert] = "Please enter a search query" if params[:query] && params[:query].empty?
    @results = Edition.published.with_title_containing(params[:query].strip) if params[:query].present?
  end

  def add_by_url; end

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
