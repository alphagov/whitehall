class PublicationsController < DocumentsController
  def index
    params[:page] ||= 1
    params[:direction] ||= "before"
    @filter = Whitehall::DocumentFilter.new(all_publications, params)

    respond_to do |format|
      format.html
      format.json do
        render json: PublicationFilterJsonPresenter.new(@filter)
      end
      format.atom do
        @publications = @filter.documents.by_published_at
      end
    end
  end

  def show
    @related_policies = @document.published_related_policies
    @topics = @related_policies.map { |d| d.topics }.flatten.uniq
  end

private

  def all_publications
    Publication.published.includes(:document, :organisations, :attachments)
  end

  def document_class
    Publication
  end
end
