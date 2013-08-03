class AnnouncementsController < PublicFacingController
  include CacheControlHelper

  before_filter :redirect_to_canonical_url
  respond_to :html, :json
  respond_to :atom, only: :index

  class SearchAnnouncementsDecorator < SimpleDelegator
    def initialize(filter, view_context)
      super(filter)
      @view_context = view_context
    end

    def documents
      Whitehall::Decorators::CollectionDecorator.new(
          __getobj__.documents, AnnouncementPresenter, @view_context)
    end
  end

  def index
    clean_search_filter_params

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

  def redirect_to_canonical_url
    if request.query_parameters[:locale] == 'en'
      redir_params = request.symbolized_path_parameters.merge(request.query_parameters).symbolize_keys.except(:locale)
      redirect_to url_for(redir_params)
    end
  end

  def build_document_filter(params)
    document_filter = search_backend.new(params)
    document_filter.announcements_search
    SearchAnnouncementsDecorator.new(document_filter, view_context)
  end

  def scheduled_announcements
    Announcement.scheduled.order("scheduled_publication asc")
  end
end
