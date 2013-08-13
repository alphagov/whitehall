class WorldLocationsController < PublicFacingController
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
        priorities = WorldwidePriority.with_translations(I18n.locale).published.in_world_location(@world_location)
        @worldwide_priorities = decorate_collection(priorities, WorldwidePriorityPresenter)
        @policies = latest_presenters(Policy.with_translations(I18n.locale).published.in_world_location(@world_location))
        publications = Publication.with_translations(I18n.locale).published.in_world_location(@world_location)
        @non_statistics_publications = latest_presenters(publications.not_statistics, count: 2)
        @statistics_publications = latest_presenters(publications.statistics, count: 2)
        @announcements = latest_presenters(Announcement.with_translations(I18n.locale).published.in_world_location(@world_location), count: 2)
        @feature_list = FeatureListPresenter.new(@world_location.feature_list_for_locale(I18n.locale), view_context).limit_to(5)
        @worldwide_organisations = @world_location.worldwide_organisations
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
