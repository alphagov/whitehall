class AnnouncementsController < PublicFacingController
  include CacheControlHelper

  respond_to :html, :json
  respond_to :atom, only: :index

  class SearchAnnouncementsDecorator < SimpleDelegator
    def initialize(filter, view_context)
      super(filter)
      @view_context = view_context
    end

    def documents
      Whitehall::Decorators::CollectionDecorator.new(__getobj__.documents, AnnouncementPresenter, @view_context)
    end
  end

  def index
    clean_malformed_params_array(:topics)
    clean_malformed_params_array(:departments)
    expire_on_next_scheduled_publication(scheduled_announcements)
    @filter = build_document_filter(params.reverse_merge({ page: 1, direction: 'before' }))

    respond_to do |format|
      format.html do
        @filter = DocumentFilterPresenter.new(@filter, view_context)
      end
      format.json do
        render json: AnnouncementFilterJsonPresenter.new(@filter, view_context)
      end
      format.atom do
        @announcements = @filter.documents.sort_by(&:public_timestamp).reverse
      end
    end
  end

private

  def build_document_filter(params)
    document_filter = search_backend.new(params)
    document_filter.announcements_search
    SearchAnnouncementsDecorator.new(document_filter, view_context)
  end

  def scheduled_announcements
    Announcement.scheduled.order("scheduled_publication asc")
  end
end
