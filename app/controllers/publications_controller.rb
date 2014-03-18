class PublicationsController < DocumentsController
  enable_request_formats index: [:json, :atom]

  def index
    expire_on_next_scheduled_publication(scheduled_publications)
    @filter = build_document_filter
    @filter.publications_search

    respond_to do |format|
      format.html do
        @filter = DocumentFilterPresenter.new(@filter, view_context, PublicationesquePresenter)
      end
      format.json do
        render json: PublicationFilterJsonPresenter.new(@filter, view_context, PublicationesquePresenter)
      end
      format.atom do
        documents = Publicationesque.published_with_eager_loading(@filter.documents.map(&:id))
        @publications = Whitehall::Decorators::CollectionDecorator.new(
          documents.sort_by(&:public_timestamp).reverse, PublicationesquePresenter, view_context)
      end
    end
  end

  def show
    @related_policies = @document.statistics? ? [] : @document.published_related_policies
    set_meta_description(@document.summary)
  end

private

  def scheduled_publications
    Publicationesque.scheduled.order("scheduled_publication asc")
  end

  def document_class
    Publication
  end
end
