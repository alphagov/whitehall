class AnnouncementsController < PublicFacingController
  respond_to :html, :json

  def index
    params[:page] ||= 1
    params[:direction] ||= "before"
    @filter = Whitehall::DocumentFilter.new(all_announcements, params)
    respond_with AnnouncementFilterJsonPresenter.new(@filter)
  end

private

  def all_announcements
    Announcement.published
      .includes(:document, :organisations)
  end
end
