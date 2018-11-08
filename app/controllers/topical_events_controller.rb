class TopicalEventsController < ClassificationsController
  enable_request_formats show: :atom

  def show
    @classification = TopicalEvent.friendly.find(params[:id])
    @content_item = Whitehall.content_store.content_item(@classification.base_path)
    @publications =  find_documents({ filter_format: 'publication', count: 3 }.merge(subject))
    @consultations = find_documents({ filter_format: 'consultation', count: 3 }.merge(subject))
    @announcements = find_documents({ filter_content_store_document_type: announcement_document_types }.merge(subject))
    @detailed_guides = @classification.published_detailed_guides.includes(:translations, :document).limit(5)
    @featurings = decorate_collection(@classification.classification_featurings.includes(:image, edition: :document).limit(5), ClassificationFeaturingPresenter)

    set_slimmer_organisations_header(@classification.organisations)
    set_slimmer_page_owner_header(@classification.lead_organisations.first)
    set_meta_description(@classification.description)

    set_expiry 5.minutes
    respond_to do |format|
      format.html do
        @recently_changed_documents = find_documents({ count: 3 }.merge(subject))['results']
      end
      format.atom do
        @recently_changed_documents = find_documents({ count: 10 }.merge(subject))['results']
      end
    end
  end

private

  def find_documents(filter_params)
    SearchRummagerService.new.fetch_related_documents(filter_params)
  end

  def subject
    { filter_topical_events: @classification.slug }
  end

  def announcement_document_types
    Whitehall::AnnouncementFilterOption.all.map(&:document_type).flatten
  end
end
