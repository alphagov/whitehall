class TopicsController < PublicFacingController
  def index
    @topics = Topic.with_content.alphabetical.all
  end

  def show
    @topic = Topic.find(params[:id])
    @policies = @topic.policies.published
    @specialist_guides = @topic.specialist_guides.published.limit(5)
    @related_topics = @topic.related_topics
    @recently_changed_documents = recently_changed_documents
  end

  private

  def recently_changed_documents
    (@topic.published_related_editions + @policies).sort_by(&:published_at).reverse
  end
end
