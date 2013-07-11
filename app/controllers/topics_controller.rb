class TopicsController < ClassificationsController
  def show
    @classification = Topic.find(params[:id])
    @policies = @classification.published_policies
    @publications = decorate_collection(Publication.published_in_topic([@classification]).in_reverse_chronological_order.limit(3), PublicationesquePresenter)
    @announcements = decorate_collection(Announcement.published_in_topic([@classification]).in_reverse_chronological_order.limit(3), AnnouncementPresenter)
    @detailed_guides = @classification.detailed_guides.published.limit(5)
    @related_classifications = @classification.related_classifications
    @recently_changed_documents = @classification.recently_changed_documents
    set_slimmer_organisations_header(@classification.organisations)
    set_slimmer_page_owner_header(@classification.lead_organisations.first)
    set_meta_description(@classification.description)

    expire_on_next_scheduled_publication(@classification.scheduled_editions +
      Publication.scheduled_in_topic([@classification]) +
      Announcement.scheduled_in_topic([@classification]))

    respond_to do |format|
      format.html do
        @recently_changed_documents = @recently_changed_documents[0...3]
      end
      format.atom do
        @recently_changed_documents = @recently_changed_documents[0...10]
      end
    end
  end
end
