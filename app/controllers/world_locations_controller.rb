class WorldLocationsController < PublicFacingController
  enable_request_formats index: [:json], show: [:atom, :json]
  before_filter :load_world_location, only: :show

  def index
    respond_to do |format|
      format.json { redirect_to api_world_locations_path(format: :json) }
      format.any { @world_locations = WorldLocation.all_by_type }
    end
  end

  def show
    recently_updated_source = @world_location.published_editions.with_translations(I18n.locale).in_reverse_chronological_order
    respond_to do |format|
      format.html do
        @recently_updated = recently_updated_source.limit(3)
        priorities = WorldwidePriority.with_translations(I18n.locale).published.in_world_location(@world_location).in_reverse_chronological_order
        @worldwide_priorities = decorate_collection(priorities, WorldwidePriorityPresenter)
        @policies = latest_presenters(Policy.published.in_world_location(@world_location), translated: true)
        publications = Publication.published.in_world_location(@world_location)
        @non_statistics_publications = latest_presenters(publications.not_statistics, translated: true, count: 2)
        @statistics_publications = latest_presenters(publications.statistics, translated: true, count: 2)
        @announcements = latest_presenters(Announcement.published.in_world_location(@world_location), translated: true, count: 2)
        @feature_list = FeatureListPresenter.new(@world_location.feature_list_for_locale(I18n.locale), view_context).limit_to(5)
        @worldwide_organisations = @world_location.worldwide_organisations
        set_slimmer_world_locations_header([@world_location])
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
    @world_location = WorldLocation.with_translations(I18n.locale).find(params[:id])
  end
end
