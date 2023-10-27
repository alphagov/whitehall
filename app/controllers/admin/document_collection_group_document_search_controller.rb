class Admin::DocumentCollectionGroupDocumentSearchController < Admin::BaseController
  before_action :load_document_collection
  before_action :load_document_collection_group

  layout "design_system"

  def search_options; end

  def search
    case params[:search_option]
    when "title"
      redirect_to(action: :add_by_title, document_collection_id: @collection, group_id: @group)
    when "url"
      redirect_to(action: :add_by_url, document_collection_id: @collection, group_id: @group)
    else
      flash.now[:alert] = "Please select a search option"
      render :search_options
    end
  end

  def add_by_title
    flash.now[:alert] = "Please enter a search query" if params[:title] && params[:title].empty?
    @editions = filter.editions if params[:title].present?
  end

  def add_by_url; end

private

  def filter
    Admin::EditionFilter.new(edition_scope, current_user, edition_filter_options)
  end

  def edition_scope
    Edition.with_translations(I18n.locale)
  end

  def edition_filter_options
    params.slice(:title, :page)
          .permit!
          .to_h.reverse_merge("state" => "active")
          .symbolize_keys
          .merge(
            per_page: Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE,
          )
  end

  def load_document_collection
    @collection = DocumentCollection.includes(document: :latest_edition).find(params[:document_collection_id])
  end

  def load_document_collection_group
    @group = @collection.groups.find(params[:group_id])
    session[:document_collection_selected_group_id] = params[:group_id]
  end
end
