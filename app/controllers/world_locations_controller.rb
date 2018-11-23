class WorldLocationsController < PublicFacingController
  enable_request_formats index: [:json], show: %i[atom json]
  before_action :load_world_location, only: :show

  def index
    respond_to do |format|
      format.json do
        redirect_to api_world_locations_path(format: :json)
      end
      format.any do
        @world_locations = WorldLocation.all_by_type
        set_meta_description("Help and services in a country")
      end
    end
  end

  def show
    recently_updated_source = @world_location.published_editions.with_translations(I18n.locale).in_reverse_chronological_order
    respond_to do |format|
      format.html do
        # Don't serve world locations unless they're international delegations
        # All other world locations are served by collections
        raise ActiveRecord::RecordNotFound unless @world_location.world_location_type == WorldLocationType::InternationalDelegation
        @recently_updated = recently_updated_source.limit(3)
        publications = Publication.published.in_world_location(@world_location)
        @non_statistics_publications = latest_presenters(publications.not_statistics, translated: true, count: 2)
        @statistics_publications = latest_presenters(publications.statistics, translated: true, count: 2)
        @announcements = latest_presenters(Announcement.published.in_world_location(@world_location), translated: true, count: 2)
        @feature_list = FeatureListPresenter.new(@world_location.feature_list_for_locale(I18n.locale), view_context).limit_to(5)
        @worldwide_organisations = @world_location.worldwide_organisations
        set_meta_description("Help and services in #{@world_location.name}.")
        set_slimmer_world_locations_header([@world_location])
        set_slimmer_organisations_header(@world_location.worldwide_organisations_with_sponsoring_organisations)
      end
      format.json do
        redirect_to api_world_location_path(@world_location, format: :json)
      end
      format.atom do
        @documents = if Locale.current.english?
                       fetch_documents
                     else
                       EditionCollectionPresenter.new(recently_updated_source.limit(10), view_context)
                     end
      end
    end
  end

private

  def fetch_documents
    filter_params = {
      count: 10,
      filter_world_locations: @world_location.slug
    }
    SearchRummagerService.new.fetch_related_documents(filter_params)["results"]
  end

  def load_world_location
    @world_location = WorldLocation.with_translations(I18n.locale).find(params[:id])
  end
end
