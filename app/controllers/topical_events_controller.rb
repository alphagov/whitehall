class TopicalEventsController < ClassificationsController
  enable_request_formats show: :atom

  def show
    @classification = TopicalEvent.friendly.find(params[:id])
    @content_item = Whitehall.content_store.content_item(@classification.base_path)
    @publications = fetch_related_documents(filter_format: 'publication')
    @consultations = fetch_related_documents(filter_format: 'consultation')
    @announcements = fetch_related_documents(filter_content_store_document_type: announcement_document_types)
    @detailed_guides = @classification.published_detailed_guides.includes(:translations, :document).limit(5)
    @featurings = decorate_collection(@classification.classification_featurings.includes(:image, edition: :document).limit(5), ClassificationFeaturingPresenter)

    set_slimmer_organisations_header(@classification.organisations)
    set_slimmer_page_owner_header(@classification.lead_organisations.first)
    set_meta_description(@classification.description)

    set_expiry 5.minutes
    respond_to do |format|
      format.html do
        @recently_changed_documents = fetch_related_documents(count: 3)['results']
      end
      format.atom do
        @recently_changed_documents = fetch_related_documents(count: 10)['results']
      end
    end
  end

private

  def fetch_related_documents(additional_options = {})
    options = default_search_options.merge(additional_options)
    search_response = Whitehall.search_client.search(options)
    search_response["results"].map! { |res| RummagerDocumentPresenter.new(res) }

    search_response
  end

  def default_search_options
    {
      filter_topical_events: @classification.slug,
      count: 3,
      order: "-public_timestamp",
      fields: %w[display_type title link public_timestamp format description content_id content_store_document_type]
    }
  end

  def announcement_document_types
    Whitehall::AnnouncementFilterOption.all.map(&:document_type).flatten
  end
end
