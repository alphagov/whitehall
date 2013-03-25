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
      format.json do
        redirect_to api_world_location_path(@world_location, format: :json)
      end
      format.atom do
        @documents = EditionCollectionPresenter.new(recently_updated_source.limit(10))
      end
      format.html do
        @recently_updated = recently_updated_source.limit(3)
        @worldwide_priorities = WorldwidePriority.with_translations(I18n.locale).published.in_world_location(@world_location).in_reverse_chronological_order
        @policies = PolicyPresenter.decorate(Policy.with_translations(I18n.locale).published.in_world_location(@world_location).in_reverse_chronological_order.limit(3))
        publications = Publication.with_translations(I18n.locale).published.in_world_location(@world_location).in_reverse_chronological_order
        @non_statistics_publications = PublicationesquePresenter.decorate(publications.not_statistics.limit(2))
        @statistics_publications = PublicationesquePresenter.decorate(publications.statistics.limit(2))
        @announcements = AnnouncementPresenter.decorate(Announcement.with_translations(I18n.locale).published.in_world_location(@world_location).in_reverse_chronological_order.limit(2))
        @feature_list = FeatureListPresenter.decorate(@world_location.feature_list_for_locale(I18n.locale))
        @worldwide_organisations = @world_location.worldwide_organisations
      end
    end
  end

  private

  def load_world_location
    @world_location = WorldLocation.with_translations(I18n.locale).find(params[:id])
  end
end
