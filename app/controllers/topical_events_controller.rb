class TopicalEventsController < ClassificationsController
  def index
    redirect_to :topics
  end

  def show
    @classification = TopicalEvent.find(params[:id])
    @policies = @classification.published_policies
    @publications = PublicationesquePresenter.decorate(@classification.published_publications.in_reverse_chronological_order.limit(6))
    @announcements = AnnouncementPresenter.decorate(@classification.published_announcements.in_reverse_chronological_order.limit(6))
    @detailed_guides = @classification.detailed_guides.published.limit(5)
    @related_classifications = @classification.related_classifications
    @recently_changed_documents = @classification.recently_changed_documents
    @featured_editions = FeaturedEditionPresenter.decorate(@classification.classification_featurings.limit(6))
    set_slimmer_organisations_header(@classification.organisations)

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
