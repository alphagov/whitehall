class TopicalEventsController < ClassificationsController
  enable_request_formats show: :atom

  def show
    @topical_event = TopicalEvent.friendly.find(params[:id])
    @content_item = Whitehall.content_store.content_item(@topical_event.base_path)
    @publications =  find_documents(filter_format: 'publication', count: 3)
    @consultations = find_documents(filter_format: 'consultation', count: 3)
    @announcements = find_documents(filter_content_store_document_type: announcement_document_types, count: 3)
    @detailed_guides = @topical_event.published_detailed_guides.includes(:translations, :document).limit(5)
    @featurings = decorate_collection(@topical_event.classification_featurings.includes(:image, edition: :document).limit(5), ClassificationFeaturingPresenter)

    set_slimmer_organisations_header(@topical_event.organisations)
    set_slimmer_page_owner_header(@topical_event.lead_organisations.first)
    set_meta_description(@topical_event.description)

    set_expiry 5.minutes
    respond_to do |format|
      format.html do
        @recently_changed_documents = find_documents(count: 3)['results']
      end
      format.atom do
        @recently_changed_documents = find_documents(count: 10)['results']
      end
    end
  end

private

  def find_documents(filter_params)
    filter_params[:filter_topical_events] = @topical_event.slug
    SearchRummagerService.new.fetch_related_documents(filter_params)
  end

  def announcement_document_types
    Whitehall::AnnouncementFilterOption.all.map(&:document_type).flatten
  end
end
