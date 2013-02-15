class WorldLocationsController < PublicFacingController
  before_filter :load_world_location, only: :show

  def index
    @world_locations = WorldLocation.all_by_type
  end

  def show
    recently_updated_source = @world_location.published_editions.in_reverse_chronological_order
    respond_to do |format|
      format.atom do
        @documents = EditionCollectionPresenter.new(recently_updated_source.limit(10))
      end
      format.html do
        @recently_updated = recently_updated_source.limit(3)
        @international_priorities = InternationalPriority.with_translations(I18n.locale).published.in_world_location(@world_location).in_reverse_chronological_order
        @policies = PolicyPresenter.decorate(Policy.published.in_world_location(@world_location).in_reverse_chronological_order.limit(3))
        @non_statistics_publications = PublicationesquePresenter.decorate(Publication.published.not_statistics.in_world_location(@world_location).in_reverse_chronological_order.limit(2))
        @statistics_publications = PublicationesquePresenter.decorate(Publication.published.statistics.in_world_location(@world_location).in_reverse_chronological_order.limit(2))
        @announcements = AnnouncementPresenter.decorate(Announcement.published.in_world_location(@world_location).in_reverse_chronological_order.limit(2))
        @featured_editions = FeaturedEditionPresenter.decorate(@world_location.featured_edition_world_locations.limit(5))
        @worldwide_offices = @world_location.worldwide_offices
      end
    end
  end

  private

  def load_world_location
    @world_location = WorldLocation.with_translations(I18n.locale).find(params[:id])
  end
end
