class TopicalEventsController < ClassificationsController
  def index
    redirect_to :topics
  end

  def show
    @classification = TopicalEvent.find(params[:id])
    @policies = @classification.published_policies.includes(:translations, :document)
    @publications = fetch_associated(:published_publications, PublicationesquePresenter)
    @consultations = fetch_associated(:published_consultations, PublicationesquePresenter)
    @announcements = fetch_associated(:published_announcements, AnnouncementPresenter)
    @detailed_guides = @classification.published_detailed_guides.includes(:translations, :document).limit(5)
    @related_classifications = @classification.related_classifications
    @featured_editions = decorate_collection(@classification.classification_featurings.includes(:image, edition: :document).limit(5), FeaturedEditionPresenter)
    set_slimmer_organisations_header(@classification.organisations)
    set_slimmer_page_owner_header(@classification.lead_organisations.first)
    set_meta_description(@classification.description)

    set_expiry 5.minutes
    respond_to do |format|
      format.html do
        @recently_changed_documents = @classification.latest(3)
      end
      format.atom do
        @recently_changed_documents = @classification.latest(10)
      end
    end
  end

  private
    def fetch_associated(type, presenter_class)
      editions = @classification
        .send(type)
        .in_reverse_chronological_order
        .includes(:translations, :document)
        .limit(3)
      decorate_collection(editions, presenter_class)
    end
end
