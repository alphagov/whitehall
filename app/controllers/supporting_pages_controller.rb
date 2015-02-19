class SupportingPagesController < DocumentsController
  prepend_before_filter :redirect_legacy_supporting_page_slugs, :find_policy
  before_filter :set_analytics_format, only: [:show]

  def index
    if preview? && @policy.has_active_supporting_pages?
      redirect_to preview_document_path(@policy.active_supporting_pages.first,
                                        policy_id: @policy.document)
    elsif @policy.has_published_supporting_pages?
      redirect_to public_document_path(@policy.published_supporting_pages.first,
                                       policy_id: @policy.document)
    else
      render_not_found
    end
  end

  def show
    @recently_changed_documents = Edition.published.related_to(@policy).in_reverse_chronological_order
    set_slimmer_organisations_header(@policy.organisations)
  end

private

  def document_class
    SupportingPage
  end

  def find_policy
    if preview?
      @policy = Document.at_slug('Policy', params[:policy_id]).try(:latest_edition)
      # Fall back to the non-preview behaviour if user isn't allowed to preview
      @policy = nil unless can_preview?(@policy)
    end

    @policy ||= Policy.published_as(params[:policy_id]) or render_not_found
  end

  def redirect_legacy_supporting_page_slugs
    redirect = SupportingPageRedirect.find_by(policy_document_id: @policy.document.id, original_slug: params[:id])
    redirect_to redirect.destination if redirect
  end

  def analytics_format
    :policy
  end

  def set_slimmer_headers_for_document
    set_slimmer_organisations_header(@policy.importance_ordered_organisations)
    set_slimmer_page_owner_header(@policy.lead_organisations.first)
  end
end
