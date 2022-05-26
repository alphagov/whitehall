class TopicalEventsController < ClassificationsController
  enable_request_formats show: :atom

  CLOSED_FEEDS = {
    "coronavirus-covid-19-uk-government-response" => {
      public_timestamp: Time.zone.iso8601("2020-06-05T17:00:00"),
      title: "coronavirus (COVID-19)",
      link: "/search/all.atom?level_one_taxon=5b7b9532-a775-4bd2-a3aa-6ce380184b6c&order=most-viewed",
    },
  }.freeze

  def show
    @topical_event = TopicalEvent.friendly.find(params[:id])
    @topical_event_lead_description = @topical_event.summary
    @topical_event_secondary_description = @topical_event.description
    @content_item = Whitehall.content_store.content_item(@topical_event.base_path)
    @publications =  find_documents(filter_format: "publication", count: 3)
    @consultations = find_documents(filter_format: "consultation", count: 3)
    @announcements = find_documents(filter_content_store_document_type: announcement_document_types, count: 3)
    @travel_advice = []
    afghanistan_travel_advice if @topical_event.slug == "afghanistan-uk-government-response"
    @detailed_guides = @topical_event.published_detailed_guides.includes(:translations, :document).limit(5)
    @featurings = decorate_collection(@topical_event.classification_featurings.includes(:image, edition: :document).limit(5), ClassificationFeaturingPresenter)

    set_slimmer_organisations_header(@topical_event.organisations)
    set_slimmer_page_owner_header(@topical_event.lead_organisations.first)
    set_meta_description(combined_description)

    set_expiry 5.minutes
    respond_to do |format|
      format.html do
        @recently_changed_documents = find_documents(count: 3)["results"]
      end
      format.atom do
        @recently_changed_documents = atom_documents
      end
    end
  end

private

  def afghanistan_travel_advice
    afghanistan_travel_advice ||= Whitehall.content_store.content_item("/foreign-travel-advice/afghanistan").to_h
    @travel_advice << afghanistan_travel_advice
  end

  def find_documents(filter_params)
    filter_params[:filter_topical_events] = @topical_event.slug
    SearchRummagerService.new.fetch_related_documents(filter_params)
  end

  def announcement_document_types
    Whitehall::AnnouncementFilterOption.all.map(&:document_type).flatten
  end

  def atom_documents
    return [closed_feed_document] if closed_feed

    find_documents(count: 10)["results"]
  end

  def closed_feed
    @closed_feed ||= CLOSED_FEEDS[params[:id]]
  end

  def closed_feed_document
    RummagerDocumentPresenter.new(
      closed_feed.stringify_keys.merge(
        "display_type" => "Replacement feed",
        "description" => "This #{closed_feed[:title]} RSS feed is being replaced with a new feed from Search - GOV.UK",
      ),
    )
  end

  def combined_description
    [@topical_event.summary, @topical_event.description].join("\r\n")
  end
end
