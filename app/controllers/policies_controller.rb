class PoliciesController < DocumentsController
  before_filter :find_document, only: [:show, :activity]

  respond_to :html
  respond_to :atom, only: :activity
  respond_to :json, only: :index

  def index
    params[:page] ||= 1
    params[:direction] ||= "alphabetical"
    @filter = Whitehall::DocumentFilter.new(policies, params)
    respond_with PolicyFilterJsonPresenter.new(@filter)
  end

  def show
    @policy = @document
    @countries = @policy.countries
    @recently_changed_documents = Edition.published.related_to(@policy).by_published_at
    @show_navigation = (@policy.supporting_pages.any? or @recently_changed_documents.any?)
  end

  def activity
    @policy = @document
    @recently_changed_documents = Edition.published.related_to(@policy).by_published_at
    if @recently_changed_documents.empty?
      render text: "Not found", status: :not_found
    end
  end

  private

  def document_class
    Policy
  end

  def policies
    Policy.published.includes(:document)
  end
end
