class ClassificationsController < PublicFacingController
  include CacheControlHelper

  def index
    @topics = Topic.with_policies.alphabetical.all
    @topical_events = TopicalEvent.alphabetical.all #TODO: with_assosicated_content
  end

  def show
    @topic = Classification.find(params[:id])
    @policies = @topic.published_policies
    expire_on_next_scheduled_publication(@topic.scheduled_editions +
      Publication.scheduled_in_topic([@topic]) +
      Announcement.scheduled_in_topic([@topic]))
    @publications = PublicationesquePresenter.decorate(Publication.published_in_topic([@topic]).in_reverse_chronological_order.limit(3))
    @announcements = AnnouncementPresenter.decorate(Announcement.published_in_topic([@topic]).in_reverse_chronological_order.limit(3))
    @detailed_guides = @topic.detailed_guides.published.limit(5)
    @related_classifications = @topic.related_classifications
    @recently_changed_documents = @topic.recently_changed_documents
    set_slimmer_organisations_header(@topic.organisations)

    respond_to do |format|
      format.html {
        @recently_changed_documents = @recently_changed_documents[0...3]
      }
      format.atom {
        @recently_changed_documents = @recently_changed_documents[0...10]
      }
    end
  end
end
