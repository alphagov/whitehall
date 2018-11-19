class WorldLocationNewsController < PublicFacingController
  enable_request_formats index: %i[atom json]
  before_action :load_world_location, only: :index

  def index
    recently_updated_source = @world_location.published_editions.with_translations(I18n.locale).in_reverse_chronological_order
    respond_to do |format|
      format.html do
        set_meta_description("What the UK government is doing in #{@world_location.name}.")
        set_slimmer_world_locations_header([@world_location])

        @recently_updated = recently_updated_source.limit(3)
        publications = Publication.published.in_world_location(@world_location)
        @non_statistics_publications = latest_presenters(publications.not_statistics, translated: true, count: 2)
        @statistics_publications = latest_presenters(publications.statistics, translated: true, count: 2)
        @announcements = if Locale.current.english?
                           fetch_documents(count: 2, filter_content_store_document_type: announcement_document_types)
                         else
                           latest_presenters(Announcement.published.in_world_location(@world_location), translated: true, count: 2)
                         end
        @feature_list = FeatureListPresenter.new(@world_location.feature_list_for_locale(I18n.locale), view_context).limit_to(5)
      end
      format.json do
        redirect_to api_world_location_path(@world_location, format: :json)
      end
      format.atom do
        @documents = EditionCollectionPresenter.new(recently_updated_source.limit(10), view_context)
      end
    end
  end

private

  def load_world_location
    @world_location = WorldLocation.with_translations(I18n.locale).find(params[:world_location_id])
  end

  def fetch_documents(additional_options = {})
    options = search_options.merge(additional_options)
    search_response = Whitehall.search_client.search(options)
    search_response["results"].map { |res| RummagerDocumentPresenter.new(res) }
  end

  def search_options
    {
      filter_world_locations: @world_location.slug,
      order: "-public_timestamp",
      fields: %w[display_type title link public_timestamp content_store_document_type]
    }
  end

  def announcement_document_types
    non_world_announcement_types = Whitehall::AnnouncementFilterOption.all.map(&:document_type).flatten
    %w(world_location_news_article world_news_story).concat(non_world_announcement_types)
  end
end
