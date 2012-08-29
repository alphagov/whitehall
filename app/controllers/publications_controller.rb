class PublicationsController < DocumentsController

  def index
    load_filtered_publications(params)

    respond_to do |format|
      format.html
      format.json do
        render json: PublicationFilterJsonPresenter.new(@filter).json
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

  def load_filtered_publications(params)
    @filter = Whitehall::DocumentFilter.new(all_publications)
    @filter.
      by_topics(params[:topics]).
      by_organisations(params[:departments]).
      by_keywords(params[:keywords]).
      by_date(params[:date] || Date.today.to_s, params[:direction]).
      paginate(params[:page] || 1)
  end
end
