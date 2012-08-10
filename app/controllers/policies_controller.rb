class PoliciesController < DocumentsController
  before_filter :find_document, only: [:show, :activity]

  def index
    @policies = Policy.published.by_published_at
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
    else
      respond_to do |format|
        format.html
        format.atom
      end
    end
  end

  private

  def document_class
    Policy
  end
end
