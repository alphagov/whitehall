class PublicationsController < DocumentsController
  class SearchPublicationesqueDecorator < SimpleDelegator
    def initialize(filter, view_context)
      super(filter)
      @view_context = view_context
    end

    def documents
      Whitehall::Decorators::CollectionDecorator.new(__getobj__.documents, PublicationesquePresenter, @view_context)
    end
  end

  def index
    clean_search_filter_params

    expire_on_next_scheduled_publication(scheduled_publications)
    @filter = build_document_filter(params.reverse_merge({ page: 1, direction: 'before' }))

    respond_to do |format|
      format.html do
        @filter = DocumentFilterPresenter.new(@filter, view_context)
      end
      format.json do
        render json: PublicationFilterJsonPresenter.new(@filter, view_context)
      end
      format.atom do
        @publications = @filter.documents.sort_by(&:public_timestamp).reverse
      end
    end
  end

  def show
    @related_policies = @document.statistics? ? [] : @document.published_related_policies
    set_slimmer_organisations_header(@document.organisations)
    set_slimmer_page_owner_header(@document.lead_organisations.first)
  end

private

  def build_document_filter(params)
    document_filter = search_backend.new(params)
    document_filter.publications_search
    SearchPublicationesqueDecorator.new(document_filter, view_context)
  end

  def scheduled_publications
    Publicationesque.scheduled.order("scheduled_publication asc")
  end

  def document_class
    Publication
  end
end
