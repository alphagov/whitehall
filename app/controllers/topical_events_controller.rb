class TopicalEventsController < ClassificationsController
  def index
    redirect_to :topics
  end

  def show
    @topical_event = TopicalEvent.find(params[:id])
    @policies = @topical_event.published_policies
    @publications = PublicationesquePresenter.decorate(@topical_event.published_publications.in_reverse_chronological_order.limit(6))
    @announcements = AnnouncementPresenter.decorate(@topical_event.published_announcements.in_reverse_chronological_order.limit(6))
    @detailed_guides = @topical_event.detailed_guides.published.limit(5)
    @related_classifications = @topical_event.related_classifications
    @recently_changed_documents = @topical_event.recently_changed_documents
    @featured_editions = FeaturedEditionPresenter.decorate(@topical_event.classification_featurings.limit(6))
    set_slimmer_organisations_header(@topical_event.organisations)

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
