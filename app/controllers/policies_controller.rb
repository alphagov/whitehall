class PoliciesController < DocumentsController
  include CacheControlHelper

  enable_request_formats index: [:json], activity: [:atom]

  before_filter :find_document, only: [:show, :activity]
  before_filter :set_slimmer_headers_for_document, only: [:show, :activity]
  before_filter :set_analytics_format, only: [:show, :activity]

  def index
    clean_search_filter_params

    @filter = build_document_filter(params.reverse_merge({ page: 1 }))

    respond_to do |format|
      format.html do
        @filter = DocumentFilterPresenter.new(@filter, view_context, PolicyPresenter)
      end
      format.json do
        render json: PolicyFilterJsonPresenter.new(@filter, view_context, PolicyPresenter)
      end
    end
  end

  def show
    @policy = @document
    @world_locations = @policy.world_locations
    @recently_changed_documents = Edition.published.related_to(@policy).in_reverse_chronological_order
    @show_navigation = (@policy.has_published_supporting_pages? || @recently_changed_documents.any?)
    set_meta_description(@document.summary)
  end

  def activity
    @policy = @document
    @recently_changed_documents = Edition.published.related_to(@policy).with_translations(I18n.locale).in_reverse_chronological_order.page(params[:page]).per(40)
    expire_on_next_scheduled_publication(Edition.scheduled.related_to(@policy))

    if @recently_changed_documents.empty?
      render text: "Not found", status: :not_found
    end
  end

  private
  def document_class
    Policy
  end

  def build_document_filter(params)
    document_filter = search_backend.new(params)
    document_filter.policies_search
    document_filter
  end

  def analytics_format
    :policy
  end
end
