class AnnouncementsController < DocumentsController
  respond_to :html, :json
  respond_to :atom, only: :index

  def index
    clean_search_filter_params

    expire_on_next_scheduled_publication(scheduled_announcements)
    @filter = build_document_filter(params.reverse_merge({ page: 1 }))

    respond_to do |format|
      format.html do
        @filter = DocumentFilterPresenter.new(@filter, view_context, AnnouncementPresenter)
      end
      format.json do
        render json: AnnouncementFilterJsonPresenter.new(@filter, view_context, AnnouncementPresenter)
      end
      format.atom do
        documents = load_editions_by_id(@filter.documents.map(&:id))
        @announcements = Whitehall::Decorators::CollectionDecorator.new(
          documents.sort_by(&:public_timestamp).reverse, AnnouncementPresenter, view_context)
      end
    end
  end

private
  def build_document_filter(params)
    document_filter = search_backend.new(params)
    document_filter.announcements_search
    document_filter
  end

  def scheduled_announcements
    Announcement.scheduled.order("scheduled_publication asc")
  end
end
