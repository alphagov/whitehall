class PoliciesController < DocumentsController
  include CacheControlHelper

  before_filter :find_document, only: [:show, :activity]
  before_filter :set_analytics_format, only: [:show, :activity]

  respond_to :html
  respond_to :atom, only: :activity

  class SearchPoliciesDecorator < SimpleDelegator
    def initialize(filter, view_context)
      super(filter)
      @view_context = view_context
    end

    def documents
      Whitehall::Decorators::CollectionDecorator.new(__getobj__.documents, PolicyPresenter, @view_context)
    end
  end

  def index
    clean_search_filter_params

    @filter = build_document_filter(params.reverse_merge({ page: 1, direction: 'alphabetical' }))

    respond_to do |format|
      format.html do
        @filter = DocumentFilterPresenter.new(@filter, view_context)
      end
      format.json do
        render json: PolicyFilterJsonPresenter.new(@filter, view_context)
      end
    end
  end

  def show
    @policy = @document
    @world_locations = @policy.world_locations
    @recently_changed_documents = Edition.published.related_to(@policy).in_reverse_chronological_order
    @show_navigation = (@policy.supporting_pages.any? or @recently_changed_documents.any?)
    set_slimmer_organisations_header(@policy.organisations)
    set_slimmer_page_owner_header(@policy.lead_organisations.first)
  end

  def activity
    @policy = @document
    @recently_changed_documents = Edition.published.related_to(@policy).in_reverse_chronological_order.page(params[:page]).per(40)
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
    SearchPoliciesDecorator.new(document_filter, view_context)
  end

  def analytics_format
    :policy
  end
end
