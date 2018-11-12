class AnnouncementsController < DocumentsController
  enable_request_formats index: %i[json atom]

  def index
    expire_on_next_scheduled_publication(scheduled_announcements)
    @filter = build_document_filter("announcements")
    @filter.announcements_search
    presenter = AnnouncementPresenter if params[:locale].present?

    respond_to do |format|
      format.html do
        @content_item = Whitehall
          .content_store
          .content_item("/government/announcements")
          .to_hash

        @filter = AnnouncementFilterJsonPresenter.new(
          @filter, view_context, presenter
        )
      end
      format.json do
        render json: AnnouncementFilterJsonPresenter.new(
          @filter, view_context, presenter
        )
      end
      format.atom do
        @announcements = @filter.documents
      end
    end
  end

private

  def scheduled_announcements
    Announcement.scheduled.order("scheduled_publication asc")
  end
end
