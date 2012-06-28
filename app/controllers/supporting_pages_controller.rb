class SupportingPagesController < PublicFacingController
  before_filter :find_policy
  before_filter :find_supporting_page, only: [:show]

  def index
    @supporting_pages = @policy.supporting_pages
  end

  def show
    @recently_changed_documents = Edition.published.related_to(@policy).by_published_at
    @document = @policy
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