class WorldLocationNewsController < PublicFacingController
  enable_request_formats index: %i[atom json]
  before_action :load_world_location, only: :index

  def index
    recently_updated_source = @world_location.published_editions.with_translations(I18n.locale).in_reverse_chronological_order
    respond_to do |format|
      format.html do
        set_meta_description("What the UK government is doing in #{@world_location.name}.")
        set_slimmer_world_locations_header([@world_location])

        @recently_updated = Locale.current.english? ? fetch_documents(count: 3) : recently_updated_source.limit(3)
        publications = Publication.published.in_world_location(@world_location)
        @non_statistics_publications = latest_presenters(publications.not_statistics, translated: true, count: 2)
        @statistics_publications = latest_presenters(publications.statistics, translated: true, count: 2)
        @news_and_communications = fetch_news_and_communications
        @feature_list = FeatureListPresenter.new(@world_location.feature_list_for_locale(I18n.locale), view_context).limit_to(5)
      end
      format.json do
        redirect_to api_world_location_path(@world_location, format: :json)
      end
      format.atom do
        @documents = if Locale.current.english?
                       fetch_documents(count: 10)
                     else
                       EditionCollectionPresenter.new(recently_updated_source.limit(10), view_context)
                     end
      end
    end
  end

private

  def load_world_location
    @world_location = WorldLocation.with_translations(I18n.locale).find(params[:world_location_id])
  end

  def fetch_documents(filter_params = {})
    filter_params[:filter_world_locations] = @world_location.slug
    SearchRummagerService.new.fetch_related_documents(filter_params)["results"]
  end

  def fetch_news_and_communications
    fetch_documents(count: 2, filter_content_purpose_supergroup: 'news_and_communications')
  end
end
