class TopicsController < PublicFacingController
  def index
    @topics = Topic.with_policies.alphabetical.all
  end

  def show
    @topic = Topic.find(params[:id])
    @policies = @topic.policies.published
    @detailed_guides = @topic.detailed_guides.published.limit(5)
    @related_topics = @topic.related_topics
    @recently_changed_documents = @topic.recently_changed_documents

    respond_to do |format|
      format.html
      format.atom {
        @recently_changed_documents = @recently_changed_documents[0...10]
      }
    end
  end
end
