class AnnouncementsController < PublicFacingController
  respond_to :html, :json

  class AnnouncementDecorator < SimpleDelegator
    def documents
      AnnouncementPresenter.decorate(__getobj__.documents)
    end
  end

  def index
    params[:page] ||= 1
    params[:direction] ||= "before"
    document_filter = Whitehall::DocumentFilter.new(all_announcements, params)
    @filter = AnnouncementDecorator.new(document_filter)
    respond_with AnnouncementFilterJsonPresenter.new(@filter)
  end

private

  def all_announcements
    Announcement.published
      .includes(:document, :organisations)
  end
end
