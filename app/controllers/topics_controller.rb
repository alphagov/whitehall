class TopicsController < ClassificationsController
  def show
    @classification = Topic.find(params[:id])
    @policies = @classification.published_policies
    @publications = presenters_for_latest(:publicationesque)
    @announcements = presenters_for_latest(:announcement)
    @detailed_guides = @classification.detailed_guides.published.limit(5)
    @related_classifications = @classification.related_classifications
    @recently_changed_documents = @classification.recently_changed_documents
    set_slimmer_organisations_header(@classification.organisations)
    set_slimmer_page_owner_header(@classification.lead_organisations.first)
    set_meta_description(@classification.description)

    expire_on_next_scheduled_publication(
      @classification.scheduled_editions +
      Publication.scheduled_in_topic([@classification]) +
      Announcement.scheduled_in_topic([@classification])
    )

    respond_to do |format|
      format.html do
        @recently_changed_documents = @recently_changed_documents[0...3]
      end
      format.atom do
        @recently_changed_documents = @recently_changed_documents[0...10]
      end
    end
  end

  private
  def presenters_for_latest(type)
    presenter_cls = Object.const_get(type.to_s.classify + 'Presenter')
    decorate_collection(latest_editions(type), presenter_cls)
  end

  def latest_editions(type)
    type_cls = Object.const_get(type.to_s.classify)
    scope = type_cls.published_in_topic([@classification])
    scope.in_reverse_chronological_order.limit(3)
  end
end
