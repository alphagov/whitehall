class TopicsController < ClassificationsController
  def show
    @classification = Topic.find(params[:id])
    @policies = @classification.published_policies
    @publications = latest_presenters(Publicationesque.published_in_topic([@classification]))
    @announcements = latest_presenters(Announcement.published_in_topic([@classification]))
    @detailed_guides = @classification.detailed_guides.published.limit(5)
    @related_classifications = @classification.related_classifications
    set_slimmer_organisations_header(@classification.organisations)
    set_slimmer_page_owner_header(@classification.lead_organisations.first)
    set_meta_description(@classification.description)

    expire_on_next_scheduled_publication(@classification.scheduled_editions)

    respond_to do |format|
      format.html do
        @recently_changed_documents = @classification.latest(3)
      end
      format.atom do
        @recently_changed_documents = @classification.latest(10)
      end
    end
  end
end
