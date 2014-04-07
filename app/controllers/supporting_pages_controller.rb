class SupportingPagesController < PublicFacingController
  include PermissionsChecker
  include PublicDocumentRoutesHelper

  before_filter :find_policy
  before_filter :redirect_if_required, :find_supporting_page, :set_analytics_format, only: [:show]

  def index
    if should_preview? && @policy.has_active_supporting_pages?
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
    @document = @policy
    @recently_changed_documents = Edition.published.related_to(@policy).in_reverse_chronological_order
    set_slimmer_organisations_header(@policy.organisations)
  end

private
  def find_policy
    if should_preview?
      @policy = Document.at_slug('Policy', params[:policy_id]).try(:latest_edition)
      # Fall back to the non-preview behaviour if user isn't allowed to preview
      @policy = nil unless can_preview?(@policy)
    end

    @policy ||= Policy.published_as(params[:policy_id]) or render_not_found
  end

  # When supporting pages were converted to editions some of the slugs had to
  # be changed. The changes are kept in the supporting_page_redirects table in
  # the database.
  def redirect_if_required
    redirect = SupportingPageRedirect.find_by_policy_document_id_and_original_slug(@policy.document.id, params[:id])
    redirect_to redirect.destination if redirect
  end

  def find_supporting_page
    if should_preview?
      @supporting_page = Document.at_slug('SupportingPage', params[:id]).try(:latest_edition)
      render_not_found unless can_preview?(@supporting_page)
    else
      @supporting_page = Document.at_slug('SupportingPage', params[:id]).try(:published_edition)
      render_not_found unless @policy.has_visible_supporting_page?(@supporting_page)
    end
  end

  def analytics_format
    :policy
  end

  def should_preview?
    params[:preview]
  end
end
