class Admin::DashboardController < Admin::BaseController

  def index
    if current_user.organisation
      @draft_documents = Edition.authored_by(current_user).where(state: 'draft').includes(:translations, :versions).in_reverse_chronological_order
      @reviewables = fetch_reviewable
      @force_published_documents = current_user.organisation.editions.force_published.includes(:translations, :versions).in_reverse_chronological_order.limit(5)
    end
  end

private

  def fetch_reviewable
    response = RestClient.get("http://127.0.0.1:3206/content/reviews")
    build_links(JSON.parse(response.body))
  end

  def build_links(results)
    return nil unless results

    items = []
    results.each do |result|
      item = Document.find_by(content_id: result["content_id"])

      reviewable_item = OpenStruct.new
      reviewable_item.title = result["title"]
      reviewable_item.review_by = result["review_by"]
      reviewable_item.edition = item.editions.last

      items << reviewable_item
    end

    items
  end
end
