class TopicalEventsController < ClassificationsController
  enable_request_formats show: :atom

  def show
    @classification = TopicalEvent.friendly.find(params[:id])
    @content_item = Whitehall.content_store.content_item(@classification.base_path)
    @publications = fetch_publications
    @consultations = fetch_consultations
    @announcements = fetch_announcements
    @detailed_guides = @classification.published_detailed_guides.includes(:translations, :document).limit(5)
    @related_classifications = @classification.related_classifications
    @featurings = decorate_collection(@classification.classification_featurings.includes(:image, edition: :document).limit(5), ClassificationFeaturingPresenter)

    set_slimmer_organisations_header(@classification.organisations)
    set_slimmer_page_owner_header(@classification.lead_organisations.first)
    set_meta_description(@classification.description)

    set_expiry 5.minutes
    respond_to do |format|
      format.html do
        @recently_changed_documents = fetch_related_documents(count: 3)
      end
      format.atom do
        @recently_changed_documents = fetch_related_documents(count: 10)
      end
    end
  end

private

  def fetch_publications
    fetch_documents_for_format('publication')
  end

  def fetch_consultations
    fetch_documents_for_format('consultation')
  end

  def fetch_announcements
    fetch_documents_for_format('news_article')
  end

  def fetch_documents_for_format(filter_format)
    fetch_related_documents(filter_format: filter_format)
  end

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
      fields: %w[display_type title link public_timestamp format description content_id]
    }
  end
end
