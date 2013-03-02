class PublicationsController < DocumentsController
  class SearchPublicationesqueDecorator < SimpleDelegator
    def documents
      PublicationesquePresenter.decorate(__getobj__.documents)
    end
  end

  def index
    clean_malformed_params_array(:topics)
    clean_malformed_params_array(:departments)

    expire_on_next_scheduled_publication(scheduled_publications)
    @filter = build_document_filter(params.reverse_merge({ page: 1, direction: 'before' }))

    respond_to do |format|
      format.html do
        @filter = DocumentFilterPresenter.new(@filter)
      end
      format.json do
        render json: PublicationFilterJsonPresenter.new(@filter)
      end
      format.atom do
        @publications = @filter.documents.sort_by(&:public_timestamp).reverse
      end
    end
  end

  def show
    @related_policies = @document.statistics? ? [] : @document.published_related_policies
    set_slimmer_organisations_header(@document.organisations)
  end

private

  def build_document_filter(params)
    document_filter = search_backend.new(params)
    document_filter.publications_search
    SearchPublicationesqueDecorator.new(document_filter)
  end

  def scheduled_publications
    Publicationesque.scheduled.order("scheduled_publication asc")
  end

  def document_class
    Publication
  end
end
