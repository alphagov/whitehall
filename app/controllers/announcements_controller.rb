class AnnouncementsController < PublicFacingController
  include CacheControlHelper

  respond_to :html, :json
  respond_to :atom, only: :index

  class SearchAnnouncementsDecorator < SimpleDelegator
    def documents
      AnnouncementPresenter.decorate(__getobj__.documents)
    end
  end

  def index
    clean_malformed_params_array(:topics)
    clean_malformed_params_array(:departments)
    # document_filter = Whitehall::DocumentFilter::Mysql.new(all_announcements, params.reverse_merge(default_params))
    # expire_on_next_scheduled_publication(scheduled_announcements)
    @filter = build_filter(params.reverse_merge({ page: 1, direction: 'before' }))

    respond_to do |format|
      format.html
      format.json do
        render json: AnnouncementFilterJsonPresenter.new(@filter)
      end
      format.atom do
        @announcements = @filter.documents.sort_by(&:public_timestamp).reverse
      end
    end
  end

private

  def build_filter(params)
    document_filter = Whitehall.search_backend.new(params)
    search = SearchAnnouncementsDecorator.new(document_filter)
    search.announcements_search
    search
  end

  # def all_announcements
  #   Announcement.published.includes(:document, :organisations)
  # end

  # def scheduled_announcements
  #   @scheduled_announcements ||= begin
  #     all_scheduled_announcements = Announcement.scheduled.order("scheduled_publication asc")
  #     filter = Whitehall::DocumentFilter::Mysql.new(all_scheduled_announcements, params.except(:direction))
  #     filter.documents
  #   end
  # end

end
