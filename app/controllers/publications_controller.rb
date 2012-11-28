class PublicationsController < DocumentsController
  class PublicationesqueDecorator < SimpleDelegator
    def documents
      PublicationesquePresenter.decorate(__getobj__.documents)
    end
  end

  def index
    params[:page] ||= 1
    params[:direction] ||= "before"
    document_filter = Whitehall::DocumentFilter.new(all_publications, params)
    expire_on_next_scheduled_publication(scheduled_publications)
    @filter = PublicationesqueDecorator.new(document_filter)

    respond_to do |format|
      format.html
      format.json do
        render json: PublicationFilterJsonPresenter.new(@filter)
      end
      format.atom do
        @publications = @filter.documents.sort_by(&:timestamp_for_sorting).reverse
      end
    end
  end

  def show
    @related_policies = @document.statistics? ? [] : @document.published_related_policies
    set_slimmer_organisations_header(@document.organisations)
  end

private

  def all_publications
    Publicationesque.published.includes(:document, :organisations, :attachments, response: :attachments)
  end

  def scheduled_publications
    unfiltered = Publicationesque.scheduled.order("scheduled_publication asc")
    Whitehall::DocumentFilter.new(unfiltered, params.except(:direction)).documents
  end

  def document_class
    Publication
  end
end
