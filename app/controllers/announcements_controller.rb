class AnnouncementsController < DocumentsController
  enable_request_formats index: %i[json atom]

  def index
    expire_on_next_scheduled_publication(scheduled_announcements)
    @filter = build_document_filter("announcements")
    @filter.announcements_search
    presenter = AnnouncementPresenter if params[:locale].present?

    respond_to do |format|
      format.html do
        return redirect_to_news_and_communications if is_english_locale?

        @content_item = Whitehall
          .content_store
          .content_item("/government/announcements")
          .to_hash

        @filter = AnnouncementFilterJsonPresenter.new(
          @filter, view_context, presenter
        )
      end
      format.json do
        render json: AnnouncementFilterJsonPresenter.new(
          @filter, view_context, presenter
        )
      end
      format.atom do
        return redirect_to_news_and_communications(".atom") if is_english_locale?

        @announcements = @filter.documents
      end
    end
  end

private

  def scheduled_announcements
    Announcement.scheduled.order("scheduled_publication asc")
  end

  def is_english_locale?
    # We only want to redirect English locale requests for now,
    # as translations for this finder haven't been moved to finder-frontend yet.
    params[:locale].nil?
  end

  def redirect_to_news_and_communications(format = "")
    base_path = "#{Plek.new.website_root}/search/news-and-communications#{format}"
    redirect_to("#{base_path}?#{news_and_communications_query_string}")
  end

  def news_and_communications_query_string
    {
      keywords: params['keywords'],
      level_one_taxon: params['taxons'].try(:first),
      level_two_taxon: params['subtaxons'].try(:first),
      people: params['people'],
      organisations: params['departments'],
      world_locations: params['world_locations'],
      public_timestamp: {
        from: params['from_date'],
        to: params['to_date']
      }.compact.presence,
    }.compact.to_query
  end
end
