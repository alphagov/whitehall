class PoliciesController < DocumentsController
  include CacheControlHelper

  before_filter :find_document, only: [:show, :activity]
  before_filter :set_analytics_format, only:[:show, :activity]

  respond_to :html
  respond_to :atom, only: :activity
  respond_to :json, only: :index

  def index
    params[:page] ||= 1
    params[:direction] ||= "alphabetical"

    clean_malformed_params_array(:topics)
    clean_malformed_params_array(:departments)

    @filter = Whitehall::DocumentFilter.new(policies, params)
    respond_with PolicyFilterJsonPresenter.new(@filter)
  end

  def show
    @policy = @document
    @world_locations = @policy.world_locations
    @recently_changed_documents = Edition.published.related_to(@policy).in_reverse_chronological_order
    @show_navigation = (@policy.supporting_pages.any? or @recently_changed_documents.any?)
    set_slimmer_organisations_header(@policy.organisations)
  end

  def activity
    @policy = @document
    @recently_changed_documents = Edition.published.related_to(@policy).in_reverse_chronological_order
    expire_on_next_scheduled_publication(Edition.scheduled.related_to(@policy))

    if @recently_changed_documents.empty?
      render text: "Not found", status: :not_found
    end
  end

  private
  def document_class
    Policy
  end

  def policies
    Policy.published.includes(:document)
  end

  def analytics_format
    :policy
  end
end
