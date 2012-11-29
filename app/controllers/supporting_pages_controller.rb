class SupportingPagesController < PublicFacingController
  before_filter :find_policy
  before_filter :find_supporting_page, only: [:show]
  before_filter :set_analytics_format, only: [:show]

  def index
    if @policy.supporting_pages.empty?
      render text: "Not found", status: :not_found
    else
      redirect_to policy_supporting_page_path(@policy.document, @policy.supporting_pages.first)
    end
  end

  def show
    @document = @policy
    @recently_changed_documents = Edition.published.related_to(@policy).in_reverse_chronological_order
    set_slimmer_organisations_header(@supporting_page.edition.organisations)
  end

  private

  def find_policy
    unless @policy = Policy.published_as(params[:policy_id])
      render text: "Not found", status: :not_found
    end
  end

  def find_supporting_page
    @supporting_page = @policy.supporting_pages.find(params[:id])
  end

  def analytics_format
    :policy
  end
end
