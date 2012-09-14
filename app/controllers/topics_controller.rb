class TopicsController < PublicFacingController
  def index
    @topics = Topic.with_content.alphabetical.all
  end

  def show
    @topic = Topic.find(params[:id])
    @policies = @topic.policies.published
    @specialist_guides = @topic.specialist_guides.published.limit(5)
    @related_topics = @topic.related_topics
    @recently_changed_documents = @topic.recently_changed_documents
  end
end
