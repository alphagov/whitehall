class AnnouncementsController < PublicFacingController

  def index
    params[:page] ||= 1
    params[:direction] ||= "before"
    @filter = Whitehall::DocumentFilter.new(all_announcements, params)
    respond_to do |format|
      format.html
      format.json do
        render json: AnnouncementFilterJsonPresenter.new(@filter).json
      end
      format.atom do
        @publications = @filter.documents.by_published_at
      end
    end
  end

private

  def all_announcements
    Announcement.published
      .by_first_published_at
      .includes(:document, :organisations)
  end

end
