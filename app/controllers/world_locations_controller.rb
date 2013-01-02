class WorldLocationsController < PublicFacingController
  before_filter :load_world_location, only: [:show, :about]

  def index
    @world_locations = WorldLocation.all
    @featured_world_location = WorldLocation.featured.first
  end

  def show
    respond_to do |format|
      format.atom do
        @documents = EditionCollectionPresenter.new(@world_location.published_editions.in_reverse_chronological_order.limit(10))
      end
      format.html do
        @international_priorities = InternationalPriority.published.in_world_location(@world_location).in_reverse_chronological_order
        @news_articles = NewsArticle.published.in_world_location(@world_location).in_reverse_chronological_order
        @policies = Policy.published.in_world_location(@world_location).in_reverse_chronological_order
        @speeches = Speech.published.in_world_location(@world_location).in_reverse_chronological_order
        @publications = Publication.published.in_world_location(@world_location).in_reverse_chronological_order

        @featured_news_articles = @world_location.featured_news_articles.in_reverse_chronological_order.limit(3)
      end
    end
  end

  def about
  end

  private

  def load_world_location
    @world_location = WorldLocation.find(params[:id])
  end
end
