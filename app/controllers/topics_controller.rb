class TopicsController < ClassificationsController
  def show
    @classification = Topic.find(params[:id])
    @policies = @classification.published_policies.includes(:translations, :document)
    @publications = latest_presenters(Publicationesque.published_in_topic(@classification))
    @announcements = latest_presenters(Announcement.published_in_topic(@classification))
    @detailed_guides = @classification.detailed_guides.published.includes(:translations, :document).limit(5)
    @related_classifications = @classification.related_classifications
    @featured_editions = decorate_collection(@classification.classification_featurings.includes(:image, edition: [:document, :translations]).limit(5), FeaturedEditionPresenter)
    set_slimmer_organisations_header(@classification.organisations.includes(:translations))
    set_slimmer_page_owner_header(@classification.lead_organisations.includes(:translations).first)
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
