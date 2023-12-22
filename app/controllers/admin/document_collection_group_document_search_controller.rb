class Admin::DocumentCollectionGroupDocumentSearchController < Admin::BaseController
  before_action :load_document_collection
  before_action :load_document_collection_group

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
    if params[:title].present?
      results = Edition.published.with_title_containing(params[:title].strip)
      @editions = results
                    .page(params[:page])
                    .per(Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE)
    end
  end

  def add_by_url; end

private

  def load_document_collection
    @collection = DocumentCollection.includes(document: :latest_edition).find(params[:document_collection_id])
  end

  def load_document_collection_group
    @group = @collection.groups.find(params[:group_id])
    session[:document_collection_selected_group_id] = params[:group_id]
  end
end
