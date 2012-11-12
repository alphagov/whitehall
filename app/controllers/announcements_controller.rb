class AnnouncementsController < PublicFacingController
  include CacheControlHelper

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
    expire_on_next_scheduled_publication(scheduled_announcements)
    @filter = AnnouncementDecorator.new(document_filter)
    respond_with AnnouncementFilterJsonPresenter.new(@filter)
  end

private

  def all_announcements
    Announcement.published
      .includes(:document, :organisations)
  end

  def scheduled_announcements
    @scheduled_announcements ||= begin
      all_scheduled_announcements = Announcement.scheduled.order("scheduled_publication asc")
      filter = Whitehall::DocumentFilter.new(all_scheduled_announcements, params.except(:direction))
      filter.documents
    end
  end

end
