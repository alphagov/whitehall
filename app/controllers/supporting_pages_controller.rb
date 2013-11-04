class SupportingPagesController < PublicFacingController
  include PermissionsChecker

  before_filter :find_policy
  before_filter :find_supporting_page, only: [:show]
  before_filter :set_analytics_format, only: [:show]

  def index
    if @policy.supporting_pages.empty?
      render_not_found
    else
      options = params.slice(:preview, :cachebust)
      redirect_to policy_supporting_page_path(@policy.document, @policy.supporting_pages.first.document, options)
    end
  end

  def show
    @document = @policy
    @recently_changed_documents = Edition.published.related_to(@policy).in_reverse_chronological_order
    set_slimmer_organisations_header(@policy.organisations)
  end

private
  def render_not_found
    render text: "Not found", status: :not_found
  end

  def find_policy
    if should_preview?
      @policy = Document.at_slug('Policy', params[:policy_id]).try(:latest_edition)
      # Fall back to the non-preview behaviour if user isn't allowed to preview
      @policy = nil unless can_preview?(@policy)
    end

    @policy ||= Policy.published_as(params[:policy_id]) or render_not_found
  end

  def find_supporting_page
    if should_preview?
      @supporting_page = Document.at_slug('SupportingPage', params[:id]).try(:latest_edition)
      render_not_found unless can_preview?(@supporting_page)
    else
      @supporting_page = Document.at_slug('SupportingPage', params[:id]).try(:published_edition)
      render_not_found unless @policy.supporting_pages.include?(@supporting_page)
    end
  end

  def analytics_format
    :policy
  end

  def should_preview?
    params[:preview]
  end

  def can_preview?(record)
    can?(:see, record)
  end
end
