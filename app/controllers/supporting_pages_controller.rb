class SupportingPagesController < PublicFacingController
  before_filter :find_policy
  before_filter :find_supporting_page, only: [:show]

  def index
    if @policy.supporting_pages.empty?
      render text: "Not found", status: :not_found
    else
      redirect_to policy_supporting_page_path(@policy.document, @policy.supporting_pages.first)
    end
  end

  def show
    @document = @policy
    @recently_changed_documents = Edition.published.related_to(@policy).by_published_at
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
end
