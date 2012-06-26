class TopicsController < PublicFacingController
  def index
    @topics = Topic.with_content.alphabetical.all
    @featured_topics = Topic.featured.order("updated_at DESC").limit(3)
  end

  def show
    @topic = Topic.find(params[:id])
    @policies = @topic.policies.published
    @specialist_guides = @topic.specialist_guides.published
    @related_topics = @topic.related_topics
    @recently_changed_documents = recently_changed_documents
    @featured_policies = @topic.featured_policies
  end

  private

  def recently_changed_documents
    (@topic.published_related_editions + @policies).sort_by(&:published_at).reverse
  end
end
